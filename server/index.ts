import express, { type Request, Response, NextFunction } from "express";
import { registerRoutes } from "./routes";
import { createAdminUser, createDefaultCategories } from "./migrate";
import fs from "fs";
import path from "path";

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  const path = req.path;
  
  res.on("finish", () => {
    const duration = Date.now() - start;
    if (path.startsWith("/api")) {
      let logLine = `${req.method} ${path} ${res.statusCode} in ${duration}ms`;
      console.log(`${new Date().toLocaleTimeString()} [express] ${logLine}`);
    }
  });

  next();
});

// Create necessary directories on startup
function createDirectories() {
  const directories = [
    'uploads',
    'uploads/pdfs',
    'uploads/thumbnails',
    'uploads/avatars',
    'uploads/temp',
    'uploads/pdf-edits'
  ];
  
  directories.forEach(dir => {
    const dirPath = path.join(process.cwd(), dir);
    if (!fs.existsSync(dirPath)) {
      try {
        fs.mkdirSync(dirPath, { recursive: true });
        console.log(`Directory created: ${dir}`);
      } catch (error) {
        console.error(`Failed to create directory ${dir}:`, error);
      }
    }
  });
}

// Create directories on startup
createDirectories();

// Database connection test and initialization
async function initializeDatabase() {
  const maxRetries = 5;
  let retryCount = 0;
  
  while (retryCount < maxRetries) {
    try {
      console.log("Testing database connection...");
      
      // Test database connection
      const { db } = await import('./db');
      await db.execute('SELECT 1');
      console.log("Database connection successful!");
      
      // Initialize database data
      console.log("Initializing database data...");
      
      try {
        console.log("Creating admin user...");
        await createAdminUser();
        console.log("Admin user creation completed.");
      } catch (err) {
        console.warn("Warning creating admin user:", err);
      }

      try {
        console.log("Creating default categories...");
        await createDefaultCategories();
        console.log("Default categories creation completed.");
      } catch (err) {
        console.warn("Warning creating default categories:", err);
      }
      
      console.log("Database initialization completed successfully.");
      return true;
      
    } catch (error) {
      retryCount++;
      console.error(`Database initialization attempt ${retryCount} failed:`, error);
      
      if (retryCount >= maxRetries) {
        console.error("Max retries reached. Database initialization failed.");
        throw error;
      }
      
      // Wait before retry (exponential backoff)
      const waitTime = Math.pow(2, retryCount) * 1000;
      console.log(`Retrying in ${waitTime}ms...`);
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
}

// Initialize database with retry logic
initializeDatabase().catch(error => {
  console.error("Critical error during startup:", error);
  console.error("Application will continue but may not function properly without database");
  // Don't exit process, let the application start without database
});

// Register API routes FIRST
registerRoutes(app);

// Add a middleware to prevent Vite from handling API routes
app.use('/api/*', (req, res, next) => {
  // If we get here, it means the API route wasn't handled
  // This should not happen if all API routes are properly defined
  res.status(404).json({ error: 'API endpoint not found' });
});

// Setup vite for development or static serving for production
const PORT = process.env.PORT || 5000;
let server;

if (process.env.NODE_ENV === "production") {
  // Production mode - serve static files
  const { serveStatic, log } = await import("./static");
  serveStatic(app);
  
  server = app.listen(PORT, "0.0.0.0", () => {
    log(`Server running on port ${PORT}`);
  });
} else {
  // Development mode - use vite
  const { setupVite, log } = await import("./vite");
  server = app.listen(PORT, "0.0.0.0", async () => {
    await setupVite(app, server);
    log(`Server running on port ${PORT}`);
  });
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});