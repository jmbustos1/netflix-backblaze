🎬 Netflix-Backblaze: Monolithic B2 Video App

This project is a monolithic deployment of a simple Netflix-like application, built for personal experimentation and architectural prototyping. The main objectives are:

    Test Backblaze B2 as a blob storage solution.

    Explore the B2 API for private video hosting with signed URLs.

    Create a minimal, production-like React + Golang project with a clean and extensible architecture.

    Use sqlc as a type-safe, ORM-less database engine.

    Deploy a fully containerized infrastructure using Docker, with frontend and backend running on a single EC2 instance, ready to scale.

    Manage infrastructure using Terraform.

This structure can serve as a starting point for future fullstack applications.
🧱 Architecture

🖥️ Hardware Architecture

    EC2 instance: hosts all containers (frontend + backend + database)

🧠 Software Stack

    Docker: containerization and deployment

    Golang (Gin): backend API and signed B2 URLs

    React: simple frontend movie viewer

    PostgreSQL: stores movie metadata

    Backblaze B2: stores video files

    Terraform: infrastructure as code (EC2, Security Groups, etc.)

🔧 Backend Overview

cmd/ – Main Entry Point

Contains the main() function, sets up routes, database connection, and initializes the B2 client. Also includes a seed command for creating sample metadata.

    Run with:

make seed

<details> <summary>▶️ main.go (simplified)</summary>

...
queries := db.New(conn)
b2client, err := b2.NewClient()

r.GET("/movies", func(c *gin.Context) {
    dbMovies, _ := queries.ListMovies(context.Background())
    movies := api.ConvertToMovieResponses(dbMovies)

    for i := range movies {
        if movies[i].VideoUrl != "" {
            filename := path.Base(movies[i].VideoUrl)
            signed, _ := b2client.GetSignedURL(filename, 15*time.Minute)
            movies[i].VideoUrl = signed
        }
    }

    hardcoded := []api.MovieResponse{
        {ID: 101, Title: "Inception", Year: 2010},
        {ID: 102, Title: "Interstellar", Year: 2014},
        {ID: 103, Title: "The Matrix", Year: 1999},
    }

    all := append(hardcoded, movies...)
    c.JSON(http.StatusOK, all)
})
...

</details>
internal/api/ – API & Serializers

Contains struct definitions and conversion logic from DB models to API responses.

type MovieResponse struct {
	ID          int    `json:"id"`
	Title       string `json:"title"`
	Year        int    `json:"year"`
	Description string `json:"description,omitempty"`
	VideoUrl    string `json:"video_url,omitempty"`
}

internal/b2/ – Backblaze Integration

Handles B2 authentication and signed URL generation.

func (c *Client) GetSignedURL(filename string, validFor time.Duration) (string, error) {
	token, err := c.bucket.AuthToken(context.Background(), filename, validFor)
	return fmt.Sprintf("%s/file/%s/%s?Authorization=%s", c.bucket.BaseURL(), c.bucket.Name(), filename, token), nil
}

internal/db/ – Database Layer

Contains raw SQL queries handled by sqlc. Example:

-- name: ListMovies :many
SELECT * FROM movies;

-- name: CreateMovie :one
INSERT INTO movies (title, year, description, url, video_url)
VALUES ($1, $2, $3, $4, $5)
RETURNING id, title, year, url, description, image_url, video_url, created_at;

🎨 Frontend

Simple React frontend that queries the /movies endpoint and displays movie cards:

✅ Results

Once metadata is correctly seeded and videos uploaded to B2, the app dynamically signs URLs to allow temporary access to video content:


🚀 Future Improvements

    User auth and video access control

    Custom metadata search (genres, actors)

    Playlist/favorite feature

    Separate deployments for frontend/backend (microservice mode)