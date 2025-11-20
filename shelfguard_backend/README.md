# ShelfGuard Backend API

Production-ready REST API for ShelfGuard product expiry tracking application.

## Features

- 🔐 **JWT Authentication** with refresh tokens
- 🏪 **Multi-tenant** shop management
- 📦 **Product Management** with custom fields
- 🔔 **Automated Notifications** for expiring products
- 📊 **Dashboard Statistics** and analytics
- 🔍 **Advanced Filtering** and search
- 🚀 **Firebase Cloud Messaging** for push notifications
- 📝 **Comprehensive Logging** with Winston
- 🐳 **Docker Support** for easy deployment
- ✅ **Input Validation** with express-validator
- 🛡️ **Security** with Helmet and rate limiting

## Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** PostgreSQL 15+
- **ORM:** Sequelize
- **Authentication:** JWT (jsonwebtoken)
- **Notifications:** Firebase Admin SDK
- **Logging:** Winston
- **Validation:** express-validator

## Prerequisites

- Node.js >= 18.0.0
- PostgreSQL >= 15.0
- npm >= 9.0.0

## Installation

### 1. Clone the repository

```bash
git clone <repository-url>
cd shelfguard_backend
```

### 2. Install dependencies

```bash
npm install
```

### 3. Set up environment variables

```bash
cp .env.example .env
```

Edit `.env` and configure your database and other settings:

```env
NODE_ENV=development
PORT=3000

DB_HOST=localhost
DB_PORT=5432
DB_NAME=shelfguard_db
DB_USER=postgres
DB_PASSWORD=your_password

JWT_SECRET=your_super_secret_jwt_key
REFRESH_TOKEN_SECRET=your_refresh_secret

FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

### 4. Set up database

```bash
# Create database
createdb shelfguard_db

# Run migrations
psql -U postgres -d shelfguard_db -f database/schema.sql
```

### 5. Start the server

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## Docker Deployment

### Using Docker Compose (Recommended)

```bash
# Start all services (PostgreSQL + API)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Using Docker only

```bash
# Build image
docker build -t shelfguard-backend .

# Run container
docker run -p 3000:3000 --env-file .env shelfguard-backend
```

## API Documentation

### Base URL

```
http://localhost:3000/api/v1
```

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/signup` | Register new user and shop |
| POST | `/auth/login` | Login user |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout user |
| GET | `/auth/profile` | Get user profile |

### Product Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/products` | Get all products with filters |
| GET | `/products/expiring-soon` | Get products expiring soon |
| GET | `/products/expired` | Get expired products |
| GET | `/products/dashboard-stats` | Get dashboard statistics |
| GET | `/products/:id` | Get product by ID |
| POST | `/products` | Create new product |
| PUT | `/products/:id` | Update product |
| DELETE | `/products/:id` | Delete product |

### Shop Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/shops/settings` | Get shop settings |
| PUT | `/shops/settings` | Update shop settings |
| GET | `/shops/custom-fields` | Get custom fields |
| POST | `/shops/custom-fields` | Create custom field |
| PUT | `/shops/custom-fields/:id` | Update custom field |
| DELETE | `/shops/custom-fields/:id` | Delete custom field |

### Notification Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications` | Get notification logs |
| GET | `/notifications/unread-count` | Get unread count |
| PUT | `/notifications/:id/read` | Mark as read |
| PUT | `/notifications/read-all` | Mark all as read |

## Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm run test:watch
```

## Project Structure

```
shelfguard_backend/
├── src/
│   ├── config/          # Configuration files
│   ├── controllers/     # Route controllers
│   ├── middleware/      # Custom middleware
│   ├── models/          # Database models
│   ├── routes/          # API routes
│   ├── services/        # Business logic services
│   ├── utils/           # Utility functions
│   └── server.js        # Application entry point
├── database/
│   └── schema.sql       # Database schema
├── tests/               # Test files
├── logs/                # Application logs
├── .env.example         # Environment variables template
├── Dockerfile           # Docker configuration
├── docker-compose.yml   # Docker Compose configuration
└── package.json         # Dependencies and scripts
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `PORT` | Server port | `3000` |
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |
| `DB_NAME` | Database name | `shelfguard_db` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Database password | - |
| `JWT_SECRET` | JWT secret key | - |
| `JWT_EXPIRES_IN` | Access token expiry | `1h` |
| `REFRESH_TOKEN_SECRET` | Refresh token secret | - |
| `REFRESH_TOKEN_EXPIRES_IN` | Refresh token expiry | `7d` |
| `FIREBASE_PROJECT_ID` | Firebase project ID | - |
| `FIREBASE_PRIVATE_KEY` | Firebase private key | - |
| `FIREBASE_CLIENT_EMAIL` | Firebase client email | - |

## Security Features

- ✅ JWT-based authentication
- ✅ Password hashing with bcryptjs
- ✅ Helmet.js security headers
- ✅ Rate limiting
- ✅ CORS configuration
- ✅ Input validation and sanitization
- ✅ SQL injection prevention (Sequelize ORM)
- ✅ XSS protection

## Logging

Logs are stored in the `logs/` directory:
- `combined.log` - All logs
- `error.log` - Error logs only

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.
