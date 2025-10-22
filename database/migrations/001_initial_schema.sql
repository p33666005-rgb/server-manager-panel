CREATE DATABASE IF NOT EXISTS server_manager;
USE server_manager;

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  is_admin BOOLEAN DEFAULT 0,
  api_token VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_api_token (api_token)
);

CREATE TABLE nodes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  location VARCHAR(100),
  fqdn VARCHAR(255) NOT NULL,
  daemon_token VARCHAR(255) NOT NULL,
  memory INT NOT NULL,
  disk INT NOT NULL,
  is_active BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE servers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  node_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  memory INT NOT NULL,
  disk INT NOT NULL,
  cpu INT NOT NULL,
  status ENUM('installing', 'running', 'stopped', 'suspended') DEFAULT 'installing',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (node_id) REFERENCES nodes(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status)
);

CREATE TABLE api_keys (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  permissions JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE backups (
  id INT PRIMARY KEY AUTO_INCREMENT,
  server_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  size BIGINT,
  status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
  storage_location VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  FOREIGN KEY (server_id) REFERENCES servers(id) ON DELETE CASCADE
);

CREATE TABLE audit_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  action VARCHAR(100) NOT NULL,
  details JSON,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_created_at (created_at)
);

INSERT INTO users (username, email, password, is_admin) VALUES 
('admin', 'admin@example.com', '$argon2id$v=19$m=65536,t=4,p=1$SG9sYVNhbHRlZHNhbHQx$xqP4lZPvF5E/3TKmJ0GvH+LCKhFJ2jB3DyWn5RnKJ1c', 1);