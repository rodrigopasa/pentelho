# PDF Management Platform

## Overview
A comprehensive PDF management platform designed for efficient document handling, metadata extraction, and intelligent processing.

## Project Architecture
- **Frontend**: React with TypeScript and Vite
- **Backend**: Express.js with TypeScript
- **Database**: PostgreSQL with Drizzle ORM
- **PDF Processing**: PDF.js for document rendering
- **Styling**: Tailwind CSS with ShadCN components
- **Theme System**: theme.json configuration for consistent styling

## Key Technologies
- React frontend with Vite
- TypeScript
- Drizzle ORM
- PostgreSQL database
- PDF.js for document rendering
- Tailwind CSS for styling
- Advanced PDF editing capabilities
- Slug management and redirection system

## Recent Changes
- ✓ Fixed DATABASE_URL configuration issue (2025-01-17)
- ✓ Created PostgreSQL database connection (2025-01-17)
- ✓ Resolved theme.json configuration errors (2025-01-17)
- ✓ Set up proper database schema migration (2025-01-17)
- ✓ Verified application startup and API endpoints (2025-01-17)
- ✓ Created Node.js 20 configuration files (.nvmrc, nixpacks.toml, Dockerfile) (2025-01-17)
- ✓ Fixed theme.json with proper ShadCN variant configuration (2025-01-17)
- ✓ Simplified theme.json to minimal professional configuration (2025-01-17)
- ✓ Verified build process works without validation errors (2025-01-17)
- ✓ Created comprehensive database error troubleshooting guide (2025-01-17)
- ✓ Added environment verification scripts for debugging (2025-01-17)

## Deployment Requirements

### Essential Files
1. **theme.json** - Required for ShadCN theme configuration
2. **Database Schema** - Ensure `npm run db:push` is run after deployment
3. **Environment Variables** - DATABASE_URL must be properly configured

### Pre-deployment Checklist
- [ ] Verify DATABASE_URL is set in environment variables
- [ ] Ensure theme.json exists with correct structure
- [ ] Run `npm run db:push` to create database tables
- [ ] Test all API endpoints are responding
- [ ] Verify file upload directories are created

### Common Issues & Solutions
1. **DATABASE_URL Error**: 
   - Create PostgreSQL database using Replit's database service
   - See QUICK_FIX_DATABASE_ERROR.md for detailed solution
   - Use scripts/check-environment.js to verify configuration
2. **Theme Configuration**: 
   - Simplified theme.json with minimal professional settings
   - Only 4 required fields: variant, primary, appearance, radius
3. **Missing Tables**: Run `npm run db:push` to create database schema
4. **File Upload Issues**: Application auto-creates required directories on startup

## Database Configuration
The application uses PostgreSQL with Drizzle ORM. The database connection is configured with:
- Connection pooling (max 20 connections)
- 30-second idle timeout
- 2-second connection timeout
- Automatic retry mechanism for initialization

## API Endpoints
- `/api/user` - User authentication and profile
- `/api/pdfs/recent` - Recent PDF documents
- `/api/pdfs/popular` - Popular PDF documents
- `/api/categories` - Document categories
- `/api/seo-settings` - SEO configuration

## User Preferences
- Language: Portuguese
- Communication style: Clear and direct
- Focus on preventing deployment issues
- Ensure all configurations are production-ready

## Development Workflow
1. Run `npm run dev` to start development server
2. Use `npm run db:push` for database schema changes
3. Monitor logs for any configuration issues
4. Test all endpoints before deployment

## File Structure
```
├── server/
│   ├── index.ts          # Main server entry point
│   ├── db.ts             # Database configuration
│   ├── migrate.ts        # Database initialization
│   └── routes.ts         # API routes
├── client/
│   └── src/              # React frontend
├── shared/
│   └── schema.ts         # Database schema
├── theme.json            # Theme configuration
└── uploads/              # File upload directories
```