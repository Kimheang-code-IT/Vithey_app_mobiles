/// Demo identities used only when mock auth/API is enabled.
///
/// Logged-in mock user demonstrates **Poster (HR)** usage: owns JOB posts.
/// Applied Jobs includes 4 dev mock applications so that tab can be tested.
/// Applier (Student) usage is fixture `author-1` (applies to jobs, no JOB posts).
abstract final class MockIdentities {
  static const mockUserId = 'mock-user';
  static const mockUserFullName = 'Khorn Molika';
  static const mockUserEmail = 'khornmolika@gmail.com';
}
