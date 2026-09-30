# Feature: Notification - Notification system

- Issue: #25
- Component: Notification
- Status: Done (push stubbed)
- Branch: `feature/notifications`

## Objective

Inform students about activity.

## What exists

NotificationController, DeviceTokenController; event listeners; Flutter preferences.

## Endpoints / components

GET /notifications, /notifications/unread-count; POST /devices

## Evidence

NotificationServiceTest, NotificationServiceContextTest

## Limitations

FCM OS push no-op without credentials.
