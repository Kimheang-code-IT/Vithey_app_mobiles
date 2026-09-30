#Requires -Version 5.1
<#
.SYNOPSIS
  End-to-end API smoke for Vithey gateway (Flutter contract).

.EXAMPLE
  cd backend
  .\scripts\smoke-api.ps1
#>
param(
  [string]$BaseUrl = "http://localhost:8080/api/v1",
  [string]$GatewayHealth = "http://localhost:8080/actuator/health",
  [string]$AiCoreHealth = "http://localhost:8100/health"
)

$ErrorActionPreference = "Continue"
$results = New-Object System.Collections.Generic.List[object]

function Add-Result([string]$Name, [bool]$Ok, [string]$Detail) {
  $results.Add([pscustomobject]@{ Step = $Name; Pass = $Ok; Detail = $Detail })
  $mark = if ($Ok) { "PASS" } else { "FAIL" }
  Write-Host ("[{0}] {1} - {2}" -f $mark, $Name, $Detail)
}

function Invoke-Api {
  param(
    [string]$Method,
    [string]$Path,
    [hashtable]$Headers = @{},
    [object]$Body = $null,
    [int[]]$ExpectStatus = @(200, 201, 204)
  )
  $uri = if ($Path.StartsWith("http")) { $Path } else { "$BaseUrl$Path" }
  $hdr = @{}
  foreach ($k in $Headers.Keys) { $hdr[$k] = $Headers[$k] }
  if (-not $hdr.ContainsKey("Accept")) { $hdr["Accept"] = "application/json" }
  $params = @{
    Method          = $Method
    Uri             = $uri
    Headers         = $hdr
    UseBasicParsing = $true
  }
  if ($null -ne $Body) {
    # Put Content-Type in Headers - separate -ContentType can drop Authorization on Windows PowerShell.
    $hdr["Content-Type"] = "application/json"
    $params.Headers = $hdr
    $params.Body = ($Body | ConvertTo-Json -Depth 8 -Compress)
  }
  try {
    $resp = Invoke-WebRequest @params
    $code = [int]$resp.StatusCode
    $json = $null
    if ($resp.Content -and $resp.Content.Trim().Length -gt 0) {
      try { $json = $resp.Content | ConvertFrom-Json } catch { $json = $null }
    }
    return @{ Ok = ($ExpectStatus -contains $code); Status = $code; Json = $json; Raw = $resp.Content; Error = $null }
  } catch {
    $code = 0
    $raw = $null
    if ($_.Exception.Response) {
      $code = [int]$_.Exception.Response.StatusCode
      try {
        $reader = New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())
        $raw = $reader.ReadToEnd()
      } catch { $raw = $_.ErrorDetails.Message }
    } else {
      $raw = $_.Exception.Message
    }
    $json = $null
    if ($raw) { try { $json = $raw | ConvertFrom-Json } catch {} }
    return @{ Ok = ($ExpectStatus -contains $code); Status = $code; Json = $json; Raw = $raw; Error = $_.Exception.Message }
  }
}

Write-Host ""
Write-Host "=== Vithey backend smoke ===" -ForegroundColor Cyan
Write-Host "Base: $BaseUrl"
Write-Host ""

$gw = Invoke-Api GET $GatewayHealth
$gwUp = $false
if ($gw.Ok) {
  if ($gw.Json -and $gw.Json.status -eq "UP") { $gwUp = $true }
  elseif ($gw.Raw -match '"status"\s*:\s*"UP"') { $gwUp = $true }
  elseif ($gw.Status -eq 200) { $gwUp = $true }
}
Add-Result "Gateway health" $gwUp ("status=$($gw.Status)")

$aiCore = Invoke-Api GET $AiCoreHealth
$aiOk = $aiCore.Ok -and ($aiCore.Json.data.status -eq "healthy" -or $aiCore.Json.status -eq "healthy")
Add-Result "ai_core health" $aiOk ("status=$($aiCore.Status)")

$stamp = Get-Random -Maximum 999999
$email = "smoke$stamp@aub.edu.kh"
$phone = "+8551{0:D8}" -f ($stamp % 100000000)
$password = "SecurePass123!"

$reg = Invoke-Api POST "/auth/register" -Body @{
  full_name = "Smoke Tester $stamp"
  email     = $email
  phone     = $phone
  password  = $password
  role      = "USER"
} -ExpectStatus @(200, 201)
$token = $reg.Json.data.tokens.access_token
$refresh = $reg.Json.data.tokens.refresh_token
$regDetail = if ($reg.Ok) { "$email status=$($reg.Status)" } else { "status=$($reg.Status) $($reg.Raw)" }
Add-Result "Register" ($reg.Ok -and $token) $regDetail

$login = Invoke-Api POST "/auth/login" -Body @{
  email_or_phone = $email
  password       = $password
} -ExpectStatus @(200)
if ($login.Ok) {
  $token = $login.Json.data.tokens.access_token
  $refresh = $login.Json.data.tokens.refresh_token
}
Add-Result "Login" $login.Ok ("status=$($login.Status)")

$authH = @{ Authorization = "Bearer $token" }

$me = Invoke-Api GET "/auth/me" -Headers $authH
Add-Result "GET /auth/me" ($me.Ok -and $me.Json.data.user_id) ("verified=$($me.Json.data.is_student_verified) role=$($me.Json.data.role)")

$profile = Invoke-Api GET "/users/me" -Headers $authH
Add-Result "GET /users/me" $profile.Ok ("status=$($profile.Status)")

$patch = Invoke-Api PATCH "/users/me" -Headers $authH -Body @{
  bio      = "Smoke bio $stamp"
  major    = "Computer Science"
  location = "Phnom Penh"
}
Add-Result "PATCH /users/me" $patch.Ok ("status=$($patch.Status)")

$post = Invoke-Api POST "/posts" -Headers $authH -Body @{
  type    = "JOB"
  content = "Smoke job post $stamp"
  job_meta = @{
    title       = "Smoke Intern"
    description = "Backend smoke job listing"
    requirement = "CS student"
    deadline    = "2026-12-31"
  }
} -ExpectStatus @(200, 201)
$postId = $post.Json.data.post_id
if (-not $postId) { $postId = $post.Json.data.id }
Add-Result "POST /posts" ($post.Ok -and $postId) ("post_id=$postId status=$($post.Status)")

$feed = Invoke-Api GET '/posts?page=1&limit=5' -Headers $authH
Add-Result "GET /posts (feed)" $feed.Ok ("status=$($feed.Status) count=$($feed.Json.data.Count)")

if ($postId) {
  $comment = Invoke-Api POST "/posts/$postId/comments" -Headers $authH -Body @{
    text = "Smoke comment $stamp"
  } -ExpectStatus @(200, 201)
  Add-Result "POST comment" $comment.Ok ("status=$($comment.Status)")

  $react = Invoke-Api POST "/posts/$postId/reactions" -Headers $authH -Body @{
    type = "LIKE"
  } -ExpectStatus @(200, 201, 204)
  Add-Result "POST reaction" $react.Ok ("status=$($react.Status)")
} else {
  Add-Result "POST comment" $false "skipped - no post_id"
  Add-Result "POST reaction" $false "skipped - no post_id"
}

$chat = Invoke-Api POST "/ai/chat" -Headers $authH -Body @{
  message = "How do I write a good CV?"
  topic   = "CV"
}
$msgId = $chat.Json.data.message_id
$sessionId = $chat.Json.data.session_id
Add-Result "POST /ai/chat" ($chat.Ok -and $chat.Json.data.reply) ("session=$sessionId")

$sessions = Invoke-Api GET '/ai/sessions?page=1&limit=10' -Headers $authH
Add-Result "GET /ai/sessions" $sessions.Ok ("status=$($sessions.Status)")

if ($msgId) {
  $regen = Invoke-Api POST "/ai/messages/$msgId/regenerate" -Headers $authH -Body @{}
  Add-Result "POST regenerate" $regen.Ok ("status=$($regen.Status)")
} else {
  Add-Result "POST regenerate" $false "skipped - no message_id"
}

$cv = Invoke-Api POST "/ai/cv/generate" -Headers $authH -Body @{
  language    = "en"
  target_role = "Software Engineer Intern"
}
Add-Result "POST /ai/cv/generate" $cv.Ok ("incomplete=$($cv.Json.data.incomplete_profile) status=$($cv.Status)")

$suggest = Invoke-Api POST "/ai/cv/suggest" -Headers $authH -Body @{
  section       = "summary"
  original_text = "I am a CS student learning Flutter and Spring."
}
Add-Result "POST /ai/cv/suggest" ($suggest.Ok -and $suggest.Json.data.suggested_text) ("status=$($suggest.Status)")

$feesBefore = Invoke-Api GET "/fees" -Headers $authH -ExpectStatus @(403)
Add-Result "GET /fees before verify (403)" $feesBefore.Ok ("status=$($feesBefore.Status)")

$verify = Invoke-Api POST "/students/verify" -Headers $authH -Body @{
  student_id       = "AUB-$stamp"
  university_email = $email
} -ExpectStatus @(200, 201)
Add-Result "POST /students/verify" ($verify.Ok -and $verify.Json.data.is_student_verified) ("status=$($verify.Status)")

Start-Sleep -Seconds 2
$ref = Invoke-Api POST "/auth/refresh" -Body @{ refresh_token = $refresh }
if ($ref.Ok) {
  $token = $ref.Json.data.access_token
  $refresh = $ref.Json.data.refresh_token
  $authH = @{ Authorization = "Bearer $token" }
}
Add-Result "POST /auth/refresh (STUDENT JWT)" $ref.Ok ("status=$($ref.Status)")

$feesAfter = Invoke-Api GET "/fees" -Headers $authH
Add-Result "GET /fees after verify" $feesAfter.Ok ("status=$($feesAfter.Status) count=$($feesAfter.Json.data.Count)")

$payments = Invoke-Api GET '/payments?page=1&limit=10' -Headers $authH
Add-Result "GET /payments" $payments.Ok ("status=$($payments.Status) count=$($payments.Json.data.Count)")

$convs = Invoke-Api GET '/conversations?page=1&limit=10' -Headers $authH
Add-Result "GET /conversations" $convs.Ok ("status=$($convs.Status)")

$requests = Invoke-Api GET "/message-requests" -Headers $authH
Add-Result "GET /message-requests" $requests.Ok ("status=$($requests.Status) count=$($requests.Json.data.Count)")

$stamp2 = Get-Random -Maximum 999999
$email2 = "peer$stamp2@aub.edu.kh"
$phone2 = "+8552{0:D8}" -f ($stamp2 % 100000000)
$reg2 = Invoke-Api POST "/auth/register" -Body @{
  full_name = "Peer User $stamp2"
  email     = $email2
  phone     = $phone2
  password  = $password
  role      = "USER"
} -ExpectStatus @(200, 201)
$peerId = $reg2.Json.data.user.user_id
Add-Result "Register peer user" ($reg2.Ok -and $peerId) ("peer=$peerId")

if ($peerId) {
  $reqConv = Invoke-Api POST "/message-requests" -Headers $authH -Body @{
    to_user_id      = $peerId
    initial_message = "Hi from smoke $stamp"
  } -ExpectStatus @(200, 201)
  $convId = $reqConv.Json.data.conversation_id
  Add-Result "POST /message-requests (create)" ($reqConv.Ok -and $convId) ("conv=$convId status=$($reqConv.Status)")

  $peerToken = $reg2.Json.data.tokens.access_token
  $peerH = @{ Authorization = "Bearer $peerToken" }
  $peerInbox = Invoke-Api GET "/message-requests" -Headers $peerH
  $inboxCount = @($peerInbox.Json.data).Count
  Add-Result "Peer sees message-request" ($peerInbox.Ok -and $inboxCount -ge 1) ("count=$inboxCount")

  if ($convId) {
    $accept = Invoke-Api POST "/conversations/$convId/accept" -Headers $peerH -Body @{}
    Add-Result "POST accept request" $accept.Ok ("status=$($accept.Status)")

    $send = Invoke-Api POST "/conversations/$convId/messages" -Headers $authH -Body @{
      text = "Smoke message after accept"
    } -ExpectStatus @(200, 201)
    Add-Result "POST chat message" $send.Ok ("status=$($send.Status)")
  }
} else {
  Add-Result "POST /message-requests (create)" $false "skipped"
  Add-Result "Peer sees message-request" $false "skipped"
  Add-Result "POST accept request" $false "skipped"
  Add-Result "POST chat message" $false "skipped"
}

$notif = Invoke-Api GET '/notifications?page=1&limit=10' -Headers $authH
Add-Result "GET /notifications" $notif.Ok ("status=$($notif.Status)")

$unread = Invoke-Api GET "/notifications/unread-count" -Headers $authH
Add-Result "GET /notifications/unread-count" $unread.Ok ("status=$($unread.Status)")

$cvLib = Invoke-Api GET "/users/me/cv" -Headers $authH -ExpectStatus @(200, 404)
Add-Result "GET /users/me/cv" $cvLib.Ok ("status=$($cvLib.Status); 404 ok if empty")

$history = Invoke-Api GET "/places/history" -Headers $authH -ExpectStatus @(200, 404, 503)
$mapUp = $history.Status -eq 200
Add-Result "GET /places/history" $history.Ok ("status=$($history.Status) map_up=$mapUp")

$logout = Invoke-Api POST "/auth/logout" -Headers $authH -Body @{ refresh_token = $refresh } -ExpectStatus @(200, 204)
Add-Result "POST /auth/logout" $logout.Ok ("status=$($logout.Status)")

$aiSvc = docker inspect -f "{{.State.Status}}" vithey-ai-service 2>$null
$noJavaAi = [string]::IsNullOrWhiteSpace($aiSvc) -or $aiSvc -eq "exited"
Add-Result "No vithey-ai-service container" $noJavaAi ("state=$aiSvc")

Write-Host ""
$pass = @($results | Where-Object { $_.Pass }).Count
$fail = @($results | Where-Object { -not $_.Pass }).Count
$color = if ($fail -eq 0) { "Green" } else { "Yellow" }
Write-Host "=== Summary: $pass PASS / $fail FAIL / $($results.Count) total ===" -ForegroundColor $color
Write-Host ""
$results | Format-Table -AutoSize

if (-not $mapUp) {
  Write-Host "Note: map-service is not in Eureka - places need map-service running." -ForegroundColor Yellow
}

if ($fail -gt 0) { exit 1 } else { exit 0 }
