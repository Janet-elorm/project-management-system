-- Drop database capstone_project;
Create database capstone_project;
use capstone_project;
-- Projects Table

CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    project_description VARCHAR(200),
    workspace VARCHAR(255),
    team_count INT,
    progress DECIMAL(5, 2), -- Percentage progress (e.g., 75.50)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Users Table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255),
    -- Add other user details as needed
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DESC Users;

-- Tasks Table
CREATE TABLE Tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    due_date DATE,
    priority ENUM('High', 'Medium', 'Low'),
    progress DECIMAL(5, 2), -- Percentage progress
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- UserAssignments Table (to assign tasks to users)
CREATE TABLE UserAssignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    task_id INT,
    user_id INT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ProjectTeam Table (to store the team members of a project)
CREATE TABLE ProjectTeam (
    project_team_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT,
    user_id INT,
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- DashboardMetrics Table (to store overall dashboard metrics)
CREATE TABLE DashboardMetrics (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    total_projects INT,
    total_tasks INT,
    assigned_tasks INT,
    overdue_tasks INT,
    completed_tasks INT,
    metric_date DATE UNIQUE, -- To store metrics for a specific date
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE project_invitations (
    id SERIAL PRIMARY KEY,
    project_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    status ENUM('pending', 'accepted', 'declined') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE activities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  project_id INT,
  task_title VARCHAR(255) NOT NULL,
  action VARCHAR(100) NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

ALTER TABLE Users DROP COLUMN full_name;  -- Remove full_name since we use first_name & last_name
ALTER TABLE Users ADD COLUMN first_name VARCHAR(50) NOT NULL;
ALTER TABLE Users DROP COLUMN username ;
ALTER TABLE Users ADD COLUMN last_name VARCHAR(50) NOT NULL;
ALTER TABLE Users ADD COLUMN phone_no VARCHAR(15) UNIQUE NOT NULL;
ALTER TABLE Users ADD COLUMN password VARCHAR(255) NOT NULL;
ALTER TABLE Users ADD COLUMN profile_picture VARCHAR(255);
ALTER TABLE ProjectTeam ADD COLUMN invite_status ENUM('Pending', 'Accepted') DEFAULT 'Pending';
ALTER TABLE project_invitations DROP column project_id;
ALTER TABLE project_invitations CHANGE COLUMN id invitation_id INT;
ALTER TABLE project_invitations DROP PRIMARY KEY;
ALTER TABLE project_invitations CHANGE COLUMN invitation_id invitation_id SERIAL PRIMARY KEY;
ALTER TABLE project_invitations ADD COLUMN accepted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE project_invitations MODIFY COLUMN status ENUM('Pending', 'Accepted', 'Declined') DEFAULT 'Pending';
ALTER TABLE project_invitations ADD column project_id int;
ALTER TABLE Tasks MODIFY COLUMN category ENUM('To Do', 'In Progress', 'Completed') NOT NULL;
ALTER TABLE Projects ADD COLUMN creator_id INT, ADD CONSTRAINT fk_creator FOREIGN KEY (creator_id) REFERENCES Users(user_id);
Alter table Projects ADD COLUMN due_date DATE NULL;

SHOW CREATE TABLE Projects;





DESCRIBE Users;
