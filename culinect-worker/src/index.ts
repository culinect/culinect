export interface Env {
  D1: D1Database;
}

// Function to handle CORS preflight requests
function handleOptions(request: Request) {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
  };

  return new Response(null, {
    headers,
  });
}


// Function to add CORS headers to the response
function addCORSHeaders(response: Response): Response {
  const headers = new Headers(response.headers);
  headers.set("Access-Control-Allow-Origin", "*");
  headers.set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  headers.set("Access-Control-Allow-Headers", "Content-Type, Authorization");

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers: headers,
  });
}

//Function to run a single SQL statement
async function runSQLStatement(env: Env, sql: string, params: any[] = []) {
  try {
    await env.D1.prepare(sql).bind(...params).run();
  } catch (error) {
    console.error(`Failed to execute SQL statement: ${sql}`, error);
    throw error;
  }
}
//Function to initialize the database schema
async function initializeDatabase(env: Env) {
  const statements = [
   /* `DROP TABLE IF EXISTS users;`,
    `DROP TABLE IF EXISTS followers;`,
    `DROP TABLE IF EXISTS following;`,
    `DROP TABLE IF EXISTS resumes;`,
    `DROP TABLE IF EXISTS experiences;`,
    `DROP TABLE IF EXISTS educations;`,
    `DROP TABLE IF EXISTS saved_posts;`,
    `DROP TABLE IF EXISTS company;`,
    `DROP TABLE IF EXISTS jobs;`,
    `DROP TABLE IF EXISTS job_applicants;`,
    `DROP TABLE IF EXISTS recipes;`,
    `DROP TABLE IF EXISTS conversations;`,
    `DROP TABLE IF EXISTS messages;`,*/
    `CREATE TABLE IF NOT EXISTS users (
      uid TEXT PRIMARY KEY,
      full_name TEXT NOT NULL,
      email TEXT NOT NULL,
      phone_number TEXT,
      profile_picture TEXT,
      profile_link TEXT NOT NULL,
      role TEXT,
      bio TEXT,
      joined_at TEXT,
      resume_id TEXT,
      post_count INTEGER DEFAULT 0,
      recipe_count INTEGER DEFAULT 0,
      jobs_count INTEGER DEFAULT 0,
      username TEXT,
      followers_count INTEGER DEFAULT 0,
      following_count INTEGER DEFAULT 0,
      saved_posts TEXT,
      post_links TEXT
    );`,
    `CREATE INDEX IF NOT EXISTS idx_username ON users (username);`,
    `CREATE INDEX IF NOT EXISTS idx_email ON users (email);`,
    `CREATE INDEX IF NOT EXISTS idx_joined_at ON users (joined_at);`,
    `CREATE TABLE IF NOT EXISTS followers (
      follower_id INTEGER PRIMARY KEY AUTOINCREMENT,
      follower_uid TEXT NOT NULL,
      user_uid TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS following (
      following_id INTEGER PRIMARY KEY AUTOINCREMENT,
      following_uid TEXT NOT NULL,
      user_uid TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS resumes (
      resume_id TEXT PRIMARY KEY,
      user_uid TEXT NOT NULL,
      objective TEXT,
      skills TEXT,
      certifications TEXT,
      languages TEXT,
      specializations TEXT,
      awards TEXT,
      resume_link TEXT,
      FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS experiences (
      experience_id INTEGER PRIMARY KEY AUTOINCREMENT,
      resume_id TEXT NOT NULL,
      title TEXT,
      company TEXT,
      start_date TEXT,
      end_date TEXT,
      description TEXT,
      FOREIGN KEY (resume_id) REFERENCES resumes (resume_id) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS educations (
      education_id INTEGER PRIMARY KEY AUTOINCREMENT,
      resume_id TEXT NOT NULL,
      school TEXT,
      degree TEXT,
      field_of_study TEXT,
      start_date TEXT,
      end_date TEXT,
      FOREIGN KEY (resume_id) REFERENCES resumes (resume_id) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS saved_posts (
      saved_post_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_uid TEXT NOT NULL,
      post_id TEXT NOT NULL,
      post_type TEXT NOT NULL,
      FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
    );`,
    `CREATE INDEX IF NOT EXISTS idx_saved_posts_user_uid ON saved_posts (user_uid);`,
    `CREATE INDEX IF NOT EXISTS idx_saved_posts_post_id ON saved_posts (post_id);`,
    `CREATE INDEX IF NOT EXISTS idx_saved_posts_post_type ON saved_posts (post_type);`,
    `CREATE TABLE IF NOT EXISTS company (
      company_id TEXT PRIMARY KEY,
      company_name TEXT NOT NULL,
      company_logo_url TEXT,
      social_media_link TEXT
    );`,
    `CREATE TABLE IF NOT EXISTS jobs (
      job_id TEXT PRIMARY KEY,
      author_uid TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      requirements TEXT NOT NULL,
      company_id TEXT NOT NULL,
      location TEXT NOT NULL,
      salary INTEGER NOT NULL,
      posted_date TEXT NOT NULL,
      application_method TEXT NOT NULL,
      email TEXT,
      career_page_url TEXT,
      job_type TEXT NOT NULL,
      application_deadline TEXT NOT NULL,
      skills_required TEXT NOT NULL,
      applicants_count INTEGER DEFAULT 0,
      remote_work_option BOOLEAN NOT NULL,
      FOREIGN KEY (author_uid) REFERENCES users (uid) ON DELETE CASCADE,
      FOREIGN KEY (company_id) REFERENCES company (company_id) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS job_applicants (
      job_applicant_id INTEGER PRIMARY KEY AUTOINCREMENT,
      job_id TEXT NOT NULL,
      user_uid TEXT NOT NULL,
      resume_link TEXT NOT NULL,
      application_method TEXT NOT NULL,
      application_date TEXT NOT NULL,
      FOREIGN KEY (job_id) REFERENCES jobs (job_id) ON DELETE CASCADE,
      FOREIGN KEY (user_uid) REFERENCES users (uid) ON DELETE CASCADE
    );`,
    `CREATE TABLE IF NOT EXISTS recipes (
      id TEXT PRIMARY KEY,
      author TEXT NOT NULL,
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
      ingredients TEXT,
      recipe_image_url TEXT,
      instruction_section_title TEXT,
      instruction_image TEXT,
      instruction TEXT,
      FOREIGN KEY (author) REFERENCES users(uid) ON DELETE CASCADE
    );`,
    `CREATE INDEX IF NOT EXISTS idx_recipe_author ON recipes (author);`,
    `CREATE INDEX IF NOT EXISTS idx_recipe_title ON recipes (title);`,
    `CREATE INDEX IF NOT EXISTS idx_recipe_cuisine ON recipes (cuisine);`,
    `CREATE INDEX IF NOT EXISTS idx_recipe_course ON recipes (course);`,
    `CREATE TABLE IF NOT EXISTS conversations (
      conversation_id TEXT PRIMARY KEY,
      participants TEXT NOT NULL,
      last_message_timestamp TEXT NOT NULL,
      last_message_content TEXT
    );`,
    `CREATE INDEX IF NOT EXISTS idx_conversation_participants ON conversations (participants);`,
    `CREATE TABLE IF NOT EXISTS messages (
      message_id TEXT PRIMARY KEY,
      conversation_id TEXT NOT NULL,
      sender_id TEXT NOT NULL,
      receiver_id TEXT NOT NULL,
      content TEXT,
      timestamp TEXT NOT NULL,
      is_read BOOLEAN DEFAULT FALSE,
      image_url TEXT,
      FOREIGN KEY (conversation_id) REFERENCES conversations (conversation_id) ON DELETE CASCADE,
      FOREIGN KEY (sender_id) REFERENCES users (uid) ON DELETE CASCADE,
      FOREIGN KEY (receiver_id) REFERENCES users (uid) ON DELETE CASCADE
    );`,
    `CREATE INDEX IF NOT EXISTS idx_message_conversation_id ON messages (conversation_id);`,
    `CREATE INDEX IF NOT EXISTS idx_message_sender_id ON messages (sender_id);`,
    `CREATE INDEX IF NOT EXISTS idx_message_receiver_id ON messages (receiver_id);`,
    `CREATE INDEX IF NOT EXISTS idx_message_timestamp ON messages (timestamp);`,
    `CREATE TABLE IF NOT EXISTS posts (
      post_id TEXT PRIMARY KEY,
      author_uid TEXT NOT NULL,
      fullName TEXT,
      profilePicture TEXT,
      profileLink TEXT,
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
    );`,
    `CREATE INDEX IF NOT EXISTS idx_post_author_uid ON posts (author_uid);`,
    `CREATE INDEX IF NOT EXISTS idx_post_created_at ON posts (created_at);`,
    `CREATE INDEX IF NOT EXISTS idx_post_visibility ON posts (visibility);`

  ];

  for (const statement of statements) {
    try {
      await runSQLStatement(env, statement);
      console.log(`Executed SQL statement: ${statement}`);
    } catch (error) {
      console.error(`Failed to execute SQL statement: ${statement}`, error);
      throw error;
    }
  }
  console.log("Database schema initialized successfully.");
}

export default {
   async fetch(request: Request, env: Env): Promise<Response> {
     // Handle CORS preflight requests
     if (request.method === "OPTIONS") {
       return handleOptions(request);
     }

     // Initialize database if not already initialized
     try {
       await initializeDatabase(env);
     } catch (error) {
       return addCORSHeaders(new Response(`Database Initialization Error: ${error.message}`, { status: 500 }));
     }
    const { pathname, searchParams } = new URL(request.url);

    // Handle API routes
    if (pathname === "/api/create_user" && request.method === "POST") {
      try {
        const data = await request.json();
        const { uid, full_name, email, ...rest } = data;

        const sql = `
          INSERT INTO users (uid, full_name, email, phone_number, profile_picture, profile_link, role, bio, joined_at, resume_id, post_count, recipe_count, jobs_count, username, followers_count, following_count, saved_posts, post_links)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        await runSQLStatement(env, sql, [uid, full_name, email, ...Object.values(rest)]);

        return addCORSHeaders(new Response("User created successfully", { status: 201 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }

    } else if (pathname === "/api/update_user" && request.method === "PUT") {
      try {
        const data = await request.json();
        const { uid, updates } = data;
        const keys = Object.keys(updates);
        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const values = keys.map(key => updates[key]);

        const sql = `UPDATE users SET ${setClause} WHERE uid = ?`;
        await runSQLStatement(env, sql, [...values, uid]);

        return addCORSHeaders(new Response("User updated successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/delete_user" && request.method === "DELETE") {
      try {
        const data = await request.json();
        const { uid } = data;

        const sql = `DELETE FROM users WHERE uid = ?`;
        await runSQLStatement(env, sql, [uid]);

        return addCORSHeaders(new Response("User deleted successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
} else if (pathname === "/api/create_post" && request.method === "POST") {
    try {
      const data = await request.json();
      console.log("Received data:", data);

     const {
       post_id,
       author_uid,
       fullName,
       profilePicture,
       profileLink,
       content,
       image_urls,
       video_url,
       created_at,
       likes_count,
       comments_count,
       saved_count,
       post_link,
       location,
       analytics,
       visibility,
       reactions,
     } = data;
			console.log(data);
      // Data validation (add more checks as needed)
      if (!post_id || !author_uid || !content) {
        return addCORSHeaders(

          new Response("Missing required fields for post", { status: 400 })
        );
      }

      const sql = `
        INSERT INTO posts (post_id, author_uid, fullName, profilePicture, profileLink, content, image_urls, video_url, created_at, likes_count, comments_count, saved_count, post_link, location, analytics, visibility, reactions)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `;
   console.log("post_id:", post_id);
   console.log("author_uid:", author_uid);
   console.log("fullName:", fullName);
   console.log("profilePicture", profilePicture);
   console.log("profileLink:", profileLink);
   console.log("content:", content);
   console.log("image_urls:", image_urls);
   console.log("video_url", video_url);
   console.log("created_at:", created_at);
   console.log("likes_count:", likes_count);
   console.log("comments_count:", comments_count);
   console.log("saved_count", saved_count);
   console.log("post_link:", post_link);
   console.log("location:", location);
   console.log("analytics", analytics);
   console.log("visibility:", visibility);
   console.log("reactions", reactions);
      try {
        await runSQLStatement(env, sql, [
          post_id,
          author_uid,
          fullName,
          profilePicture,
          profileLink,
          content,
          JSON.stringify(image_urls),
          video_url,
          created_at,
          likes_count,
          comments_count,
          saved_count,
          post_link,
          location,
          JSON.stringify(analytics),
          visibility,
          JSON.stringify(reactions),
        ]); // Spread syntax not applicable here due to JSON.stringify calls

        return addCORSHeaders(
          new Response("Post created successfully", { status: 201 })
        );
      } catch (error) {
        if (error.message.includes("UNIQUE constraint failed")) {
          return addCORSHeaders(
            new Response("Post with this ID already exists", { status: 409 })
          );
        } else {
          return addCORSHeaders(
            new Response(`Failed to create post: ${error.message}`, {
              status: 500,
            })
          );
        }
      }
    } catch (error) {
      return addCORSHeaders(
        new Response(`Internal Server Error: ${error.message}`, { status: 500 })
      );
    }
} else if (pathname === "/api/update_post" && request.method === "PUT") {
  try {
    const data = await request.json();
    const { postId, updates } = data;

    // Construct SQL UPDATE query
    const keys = Object.keys(updates);
    const setClause = keys.map(key => `${key} = ?`).join(', ');
    const values = keys.map(key => updates[key]);

    const sql = `UPDATE posts SET ${setClause} WHERE post_id = ?`;
    await runSQLStatement(env, sql, [...values, postId]);

    return addCORSHeaders(new Response("Post updated successfully", { status: 200 }));
  } catch (error) {
    return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
  }
} else if (pathname === "/api/delete_post" && request.method === "DELETE") {
  try {
    const data = await request.json();
    const { postId } = data;

    const sql = `DELETE FROM posts WHERE post_id = ?`;
    await runSQLStatement(env, sql, [postId]);

    return addCORSHeaders(new Response("Post deleted successfully", { status: 200 }));
  } catch (error) {
    return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
  }
} else if (pathname === "/api/create_job" && request.method === "POST") {
      try {
        const data = await request.json();
        const { jobId, authorBasicInfo, title, description, requirements, company, location, salary, postedDate, applicationMethod, email, careerPageUrl, jobType, applicationDeadline, skillsRequired, applicantsCount, remoteWorkOption } = data;

        const sql = `
          INSERT INTO jobs (jobId, authorBasicInfo, title, description, requirements, company, location, salary, postedDate, applicationMethod, email, careerPageUrl, jobType, applicationDeadline, skillsRequired, applicantsCount, remoteWorkOption)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        await runSQLStatement(env, sql, [jobId, JSON.stringify(authorBasicInfo), title, description, requirements, company, location, salary, postedDate, applicationMethod, email, careerPageUrl, jobType, applicationDeadline, skillsRequired, applicantsCount, remoteWorkOption]);

        return addCORSHeaders(new Response("Job created successfully", { status: 201 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/update_job" && request.method === "PUT") {
      try {
        const data = await request.json();
        const { jobId, updates } = data;
        const keys = Object.keys(updates);
        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const values = keys.map(key => updates[key]);

        const sql = `UPDATE jobs SET ${setClause} WHERE jobId = ?`;
        await runSQLStatement(env, sql, [...values, jobId]);

        return addCORSHeaders(new Response("Job updated successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/delete_job" && request.method === "DELETE") {
      try {
        const data = await request.json();
        const { jobId } = data;

        const sql = `DELETE FROM jobs WHERE jobId = ?`;
        await runSQLStatement(env, sql, [jobId]);


        return addCORSHeaders(new Response("Job deleted successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/create_recipe" && request.method === "POST") {
      try {
        const data = await request.json();
        const { id, author, author_image, author_name, title, description, cuisine, course, keys, badges, prep_time, cook_time, calories, num_servings, ingredient_title, ingredients, recipe_image_url, instruction_section_title, instruction_image, instruction } = data;

        const sql = `
          INSERT INTO recipes (id, author, author_image, author_name, title, description, cuisine, course, keys, badges, prep_time, cook_time, calories, num_servings, ingredient_title, ingredients, recipe_image_url, instruction_section_title, instruction_image, instruction)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        await runSQLStatement(env, sql, [id, author, author_image, author_name, title, description, cuisine, course, keys, badges, prep_time, cook_time, calories, num_servings, ingredient_title, JSON.stringify(ingredients), recipe_image_url, instruction_section_title, instruction_image, instruction]);

        return addCORSHeaders(new Response("Recipe created successfully", { status: 201 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/update_recipe" && request.method === "PUT") {
      try {
        const data = await request.json();
        const { id, updates } = data;
        const keys = Object.keys(updates);
        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const values = keys.map(key => updates[key]);

        const sql = `UPDATE recipes SET ${setClause} WHERE id = ?`;
        await runSQLStatement(env, sql, [...values, id]);

        return addCORSHeaders(new Response("Recipe updated successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/delete_recipe" && request.method === "DELETE") {
      try {
        const data = await request.json();
        const { id } = data;

        const sql = `DELETE FROM recipes WHERE id = ?`;
        await runSQLStatement(env, sql, [id]);

        return addCORSHeaders(new Response("Recipe deleted successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/create_blog" && request.method === "POST") {
      try {
        const data = await request.json();
        const { blogId, authorBasicInfo, title, content, tags, createdAt } = data;

        const sql = `
          INSERT INTO blogs (blogId, authorBasicInfo, title, content, tags, createdAt)
          VALUES (?, ?, ?, ?, ?, ?)
        `;

        await runSQLStatement(env, sql, [blogId, JSON.stringify(authorBasicInfo), title, content, JSON.stringify(tags), createdAt]);

        return addCORSHeaders(new Response("Blog created successfully", { status: 201 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/update_blog" && request.method === "PUT") {
      try {
        const data = await request.json();
        const { blogId, updates } = data;
        const keys = Object.keys(updates);
        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const values = keys.map(key => updates[key]);

        const sql = `UPDATE blogs SET ${setClause} WHERE blogId = ?`;
        await runSQLStatement(env, sql, [...values, blogId]);

        return addCORSHeaders(new Response("Blog updated successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/delete_blog" && request.method === "DELETE") {
      try {
        const data = await request.json();
        const { blogId } = data;

        const sql = `DELETE FROM blogs WHERE blogId = ?`;
        await runSQLStatement(env, sql, [blogId]);

        return addCORSHeaders(new Response("Blog deleted successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/create_conversation" && request.method === "POST") {
      try {
        const data = await request.json();
        const { conversationId, participants, lastMessageTimestamp, lastMessageContent } = data;

        const sql = `
          INSERT INTO conversations (conversationId, participants, lastMessageTimestamp, lastMessageContent)
          VALUES (?, ?, ?, ?)
        `;

        await runSQLStatement(env, sql, [conversationId, JSON.stringify(participants), lastMessageTimestamp, lastMessageContent]);

        return addCORSHeaders(new Response("Conversation created successfully", { status: 201 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/update_conversation" && request.method === "PUT") {
      try {
        const data = await request.json();
        const { conversationId, updates } = data;
        const keys = Object.keys(updates);
        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const values = keys.map(key => updates[key]);

        const sql = `UPDATE conversations SET ${setClause} WHERE conversationId = ?`;
        await runSQLStatement(env, sql, [...values, conversationId]);

        return addCORSHeaders(new Response("Conversation updated successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/delete_conversation" && request.method === "DELETE") {
      try {
        const data = await request.json();
        const { conversationId } = data;

        const sql = `DELETE FROM conversations WHERE conversationId = ?`;
        await runSQLStatement(env, sql, [conversationId]);

        return addCORSHeaders(new Response("Conversation deleted successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/create_message" && request.method === "POST") {
      try {
        const data = await request.json();
        const { messageId, senderId, receiverId, content, timestamp, isRead, imageUrl } = data;

        const sql = `
          INSERT INTO messages (messageId, senderId, receiverId, content, timestamp, isRead, imageUrl)
          VALUES (?, ?, ?, ?, ?, ?, ?)
        `;

        await runSQLStatement(env, sql, [messageId, senderId, receiverId, content, timestamp, isRead, imageUrl]);

        return addCORSHeaders(new Response("Message created successfully", { status: 201 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/update_message" && request.method === "PUT") {
      try {
        const data = await request.json();
        const { messageId, updates } = data;
        const keys = Object.keys(updates);
        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const values = keys.map(key => updates[key]);

        const sql = `UPDATE messages SET ${setClause} WHERE messageId = ?`;
        await runSQLStatement(env, sql, [...values, messageId]);

        return addCORSHeaders(new Response("Message updated successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    } else if (pathname === "/api/delete_message" && request.method === "DELETE") {
      try {
        const data = await request.json();
        const { messageId } = data;

        const sql = `DELETE FROM messages WHERE messageId = ?`;
        await runSQLStatement(env, sql, [messageId]);

        return addCORSHeaders(new Response("Message deleted successfully", { status: 200 }));
      } catch (error) {
        return addCORSHeaders(new Response(`Internal Server Error: ${error.message}`, { status: 500 }));
      }
    }

    return addCORSHeaders(new Response("Unsupported request", { status: 404 }));
  },
} satisfies ExportedHandler<Env>;
