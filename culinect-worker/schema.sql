-- Drop existing tables if they exist
--DROP TABLE IF EXISTS users;
--DROP TABLE IF EXISTS followers;
--DROP TABLE IF EXISTS following;
--DROP TABLE IF EXISTS resumes;
--DROP TABLE IF EXISTS experiences;
--DROP TABLE IF EXISTS educations;
--DROP TABLE IF EXISTS saved_posts;
--DROP TABLE IF EXISTS company;
--DROP TABLE IF EXISTS jobs;
--DROP TABLE IF EXISTS job_applicants;
--DROP TABLE IF EXISTS recipes;
--DROP TABLE IF EXISTS conversations;  -- Added for chat feature
--DROP TABLE IF EXISTS messages;  -- Added for chat feature

-- Create the users table
CREATE TABLE IF NOT EXISTS users (
    uid TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone_number TEXT,
    profile_picture TEXT,
    profile_link TEXT NOT NULL,
    role TEXT,
    bio TEXT,
    joined_at TEXT, -- Storing DateTime as ISO8601 string
    resume_id TEXT,
    post_count INTEGER DEFAULT 0,
    recipe_count INTEGER DEFAULT 0,
    jobs_count INTEGER DEFAULT 0,
    username TEXT,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    saved_posts TEXT, -- Storing list as a JSON string
    post_links TEXT  -- Storing map as a JSON string
);

-- Create indexes to optimize queries
CREATE INDEX IF NOT EXISTS idx_username ON users (username);
CREATE INDEX IF NOT EXISTS idx_email ON users (email);
CREATE INDEX IF NOT EXISTS idx_joined_at ON users (joined_at);

-- Create the followers table
CREATE TABLE IF NOT EXISTS followers (
    follower_id INTEGER PRIMARY KEY AUTOINCREMENT,
    follower_uid TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    timestamp TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
);

-- Create the following table
CREATE TABLE IF NOT EXISTS following (
    following_id INTEGER PRIMARY KEY AUTOINCREMENT,
    following_uid TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    timestamp TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
);

-- Create the resumes table
CREATE TABLE IF NOT EXISTS resumes (
    resume_id TEXT PRIMARY KEY,
    user_uid TEXT NOT NULL,
    objective TEXT,
    skills TEXT, -- Storing list as a JSON string
    certifications TEXT, -- Storing list as a JSON string
    languages TEXT, -- Storing list as a JSON string
    specializations TEXT, -- Storing list as a JSON string
    awards TEXT, -- Storing list as a JSON string
    resume_link TEXT,
    FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
);

-- Create the experiences table
CREATE TABLE IF NOT EXISTS experiences (
    experience_id INTEGER PRIMARY KEY AUTOINCREMENT,
    resume_id TEXT NOT NULL,
    title TEXT,
    company TEXT,
    start_date TEXT, -- Storing DateTime as ISO8601 string
    end_date TEXT, -- Storing DateTime as ISO8601 string
    description TEXT,
    FOREIGN KEY (resume_id) REFERENCES resumes (resume_id) ON DELETE CASCADE
);

-- Create the educations table
CREATE TABLE IF NOT EXISTS educations (
    education_id INTEGER PRIMARY KEY AUTOINCREMENT,
    resume_id TEXT NOT NULL,
    school TEXT,
    degree TEXT,
    field_of_study TEXT,
    start_date TEXT, -- Storing DateTime as ISO8601 string
    end_date TEXT, -- Storing DateTime as ISO8601 string
    FOREIGN KEY (resume_id) REFERENCES resumes (resume_id) ON DELETE CASCADE
);

-- Create the saved_posts table
CREATE TABLE IF NOT EXISTS saved_posts (
    saved_post_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_uid TEXT NOT NULL,
    post_id TEXT NOT NULL,
    post_type TEXT NOT NULL,
    FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
);

-- Indexes to optimize queries for saved posts
CREATE INDEX IF NOT EXISTS idx_saved_posts_user_uid ON saved_posts (user_uid);
CREATE INDEX IF NOT EXISTS idx_saved_posts_post_id ON saved_posts (post_id);
CREATE INDEX IF NOT EXISTS idx_saved_posts_post_type ON saved_posts (post_type);

-- Create the company table
CREATE TABLE IF NOT EXISTS company (
    company_id TEXT PRIMARY KEY,
    company_name TEXT NOT NULL,
    company_logo_url TEXT,
    social_media_link TEXT
);

-- Create the jobs table
CREATE TABLE IF NOT EXISTS jobs (
    job_id TEXT PRIMARY KEY,
    author_uid TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT NOT NULL,
    company_id TEXT NOT NULL,
    location TEXT NOT NULL,
    salary INTEGER NOT NULL,
    posted_date TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    application_method TEXT NOT NULL,
    email TEXT,
    career_page_url TEXT,
    job_type TEXT NOT NULL,
    application_deadline TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    skills_required TEXT NOT NULL,
    applicants_count INTEGER DEFAULT 0,
    remote_work_option BOOLEAN NOT NULL,
    FOREIGN KEY (author_uid) REFERENCES users (uid) ON DELETE CASCADE,
    FOREIGN KEY (company_id) REFERENCES company (company_id) ON DELETE CASCADE
);

-- Create the job_applicants table
CREATE TABLE IF NOT EXISTS job_applicants (
    job_applicant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id TEXT NOT NULL,
    user_uid TEXT NOT NULL,
    resume_link TEXT NOT NULL,
    application_method TEXT NOT NULL,
    application_date TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    FOREIGN KEY (job_id) REFERENCES jobs (job_id) ON DELETE CASCADE,
    FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
);

-- Create the recipes table
CREATE TABLE IF NOT EXISTS recipes (
    id TEXT PRIMARY KEY,
    author TEXT NOT NULL, -- Stores the user ID of the author
    author_image TEXT,
    author_name TEXT,
    title TEXT NOT NULL,
    description TEXT,
    cuisine TEXT,
    course TEXT,
    keys TEXT,
    badges TEXT,
    prep_time TEXT,
    cook_time TEXT,
    calories TEXT,
    num_servings TEXT,
    ingredient_title TEXT,
    ingredients TEXT, -- Storing list of maps as a JSON string
    recipe_image_url TEXT,
    instruction_section_title TEXT,
    instruction_image TEXT,
    instruction TEXT,
    FOREIGN KEY (author) REFERENCES users(uid) ON DELETE CASCADE
);

-- Create indexes to optimize queries
CREATE INDEX IF NOT EXISTS idx_recipe_author ON recipes (author);
CREATE INDEX IF NOT EXISTS idx_recipe_title ON recipes (title);
CREATE INDEX IF NOT EXISTS idx_recipe_cuisine ON recipes (cuisine);
CREATE INDEX IF NOT EXISTS idx_recipe_course ON recipes (course);

-- Create the conversations table
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id TEXT PRIMARY KEY,
    participants TEXT NOT NULL, -- Storing list of user IDs as a JSON string
    last_message_timestamp TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    last_message_content TEXT
);

-- Create indexes to optimize queries for conversations
CREATE INDEX IF NOT EXISTS idx_conversation_participants ON conversations (participants);

-- Create the messages table
CREATE TABLE IF NOT EXISTS messages (
    message_id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    receiver_id TEXT NOT NULL,
    content TEXT,
    timestamp TEXT NOT NULL, -- Storing DateTime as ISO8601 string
    is_read BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    FOREIGN KEY (conversation_id) REFERENCES conversations (conversation_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES users (uid) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users (uid) ON DELETE CASCADE
);

-- Create indexes to optimize queries for messages
CREATE INDEX IF NOT EXISTS idx_message_conversation_id ON messages (conversation_id);
CREATE INDEX IF NOT EXISTS idx_message_sender_id ON messages (sender_id);
CREATE INDEX IF NOT EXISTS idx_message_receiver_id ON messages (receiver_id);
CREATE INDEX IF NOT EXISTS idx_message_timestamp ON messages (timestamp);

-- Create the posts table
CREATE TABLE IF NOT EXISTS posts (
  post_id TEXT PRIMARY KEY,
  author_uid TEXT NOT NULL,
  author_basic_info TEXT, -- Store as JSON string
  content TEXT,
  image_urls TEXT, -- Store as JSON string
  video_url TEXT,
  created_at TEXT NOT NULL,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  saved_count INTEGER DEFAULT 0,
  post_link TEXT,
  location TEXT,
  analytics TEXT, -- Store as JSON string
  visibility TEXT DEFAULT 'public',
  reactions TEXT, -- Store as JSON string
  FOREIGN KEY (author_uid) REFERENCES users (uid) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_post_author_uid ON posts (author_uid);
CREATE INDEX IF NOT EXISTS idx_post_created_at ON posts (created_at);
CREATE INDEX IF NOT EXISTS idx_post_visibility ON posts (visibility);

