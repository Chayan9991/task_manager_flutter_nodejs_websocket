Here's the professional README.md file for your Task Manager REST API, wrapped in the required artifact tag:

# Task Manager REST API

This REST API provides backend services for the Task Manager app, including user authentication, task management, and user info. It uses Node.js, Express, MongoDB, and JWT authentication.

---

## Base URL

All API endpoints are available under this base URL:

[https://task-manager-flutter-nodejs-websocket.onrender.com/api](https://task-manager-flutter-nodejs-websocket.onrender.com/api)

---

## Authentication

### Register User

- **Endpoint:** `POST /register`
- **Description:** Register a new user.
- **Request Body:**
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "yourpassword",
    "phoneNumber": "1234567890"
  }
  ```
- **Response:**
  ```json
  {
    "msg": "User registered"
  }
  ```
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/register
  ```

---

### Login User

- **Endpoint:** `POST /login`
- **Description:** Login with email and password to receive a JWT token.
- **Request Body:**
  ```json
  {
    "email": "john@example.com",
    "password": "yourpassword"
  }
  ```
- **Response:**
  ```json
  {
    "token": "your_jwt_token"
  }
  ```
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/login
  ```

---

## Task Management (Protected Routes)

> **Note:** All task-related routes require an `Authorization` header with a valid JWT token:
>
> ```
> Authorization: Bearer your_jwt_token
> ```

### Get All Tasks

- **Endpoint:** `GET /tasks`
- **Description:** Retrieve all tasks for the logged-in user.
- **Response:** JSON array of task objects.
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/tasks
  ```

### Create a New Task

- **Endpoint:** `POST /tasks`
- **Description:** Create a new task.
- **Request Body:**
  ```json
  {
    "title": "New Task",
    "description": "Task details",
    "status": "pending"
  }
  ```
- **Response:** JSON object of the created task.
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/tasks
  ```

### Update a Task

- **Endpoint:** `PUT /tasks/:id`
- **Description:** Update a task by its ID.
- **Request Body:** (fields to update)
  ```json
  {
    "title": "Updated Task",
    "description": "Updated details",
    "status": "completed"
  }
  ```
- **Response:** JSON object of the updated task.
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/tasks/60d21b4667d0d8992e610c85
  ```

### Delete a Task

- **Endpoint:** `DELETE /tasks/:id`
- **Description:** Delete a task by its ID.
- **Response:**
  ```json
  {
    "msg": "Deleted",
    "id": "60d21b4667d0d8992e610c85"
  }
  ```
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/tasks/60d21b4667d0d8992e610c85
  ```

---

## User Info (Protected Route)

### Get Current User Info

- **Endpoint:** `GET /user/currentUser`
- **Description:** Retrieve information about the currently logged-in user.
- **Response:** JSON object with user details.
- **Example URL:**
  ```
  https://task-manager-flutter-nodejs-websocket.onrender.com/api/user/currentUser
  ```

---

## How to Use with Postman

1. Use the base URL plus endpoint path.
2. For **POST** and **PUT** requests, set Body type to `raw` and format as `JSON`.
3. For protected routes (`/tasks`, `/user`), include an **Authorization** header with your JWT token:
   ```
   Authorization: Bearer your_jwt_token
   ```
4. Send the request and review the JSON response.

---

## Notes

- Replace `your_jwt_token` with the actual token received from the login endpoint.
- The API expects and returns JSON data.
- Make sure to handle errors on your client side for invalid tokens or failed requests.

---

Feel free to contribute or open issues for help!

---

_Developed by Chayan Barman_

If you'd like me to generate a README for the Flutter client or deployment instructions, let me know!
