
export const templates = {

    recipe: {
      title: "New Recipe",
      body: (data) => `${data.userName} shared a recipe: ${data.title}`,
      type: "RECIPE"
    },
    post: {
      title: "New Post",
      body: (data) => `${data.userName} shared a post: ${data.title}`,
      type: "POST"
    },
    job: {
      title: "New Job Opening",
      body: (data) => `New job posted: ${data.title}`,
      type: "JOB"
    }
  };
