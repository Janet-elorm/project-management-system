# import pytest
# from fastapi.testclient import TestClient
# from main import app
# from unittest.mock import patch, MagicMock

# client = TestClient(app)

# # Mark all tests in this file to allow async tests
# pytestmark = pytest.mark.asyncio

# # 1. ✅ Regular Login Tests
# def test_login_success():
#     response = client.post("/auth/login", json={"email": "test@example.com", "password": "valid_password"})
#     assert response.status_code == 200
#     assert "access_token" in response.json()

# def test_login_failure():
#     response = client.post("/auth/login", json={"email": "invalid@example.com", "password": "wrong"})
#     assert response.status_code == 401

# # 2. ✅ Test sending invite email (mocked)
# async def test_send_invite_email():
#     mock_current_user = {"user_id": 1}

#     with patch('routes.invite.send_invite_email') as mock_send_email:
#         with patch('routes.invite.decode_jwt_token', return_value=mock_current_user):
#             response = client.post(
#                 "/test-email",
#                 headers={"Authorization": "Bearer mock_token"},
#                 json={
#                     "sender_email": "test@example.com",
#                     "receiver_email": "recipient@example.com",
#                     "project_id": 1
#                 }
#             )
#             assert response.status_code == 200
#             assert response.json() == {"status": "Email sent successfully"}
#             mock_send_email.assert_called_once()

# # 3. ✅ Test protected route
# def test_protected_route_requires_token():
#     response = client.get("/protected-endpoint")
#     assert response.status_code == 401  # Unauthorized if no token
