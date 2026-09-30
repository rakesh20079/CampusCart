# 🎓 Campus Cart — Collegiate Peer-to-Peer Marketplace

> **A secure, minimal, decluttered college marketplace app (OLX for Students).**  
> Students can list and discover pre-owned textbooks, calculators, electronics, dorm essentials, and lab gear, then reveal verified seller contact details (Phone Call, WhatsApp, Email, Campus Pickup Location) to complete transactions safely in person.

---

## 🚀 Live Cloud Deployment

- **Cloud Provider**: Amazon Web Services (AWS Free Tier)
- **Compute**: AWS EC2 (`t2.micro` / `t3.micro`, Ubuntu Server)
- **Containerization**: Docker & Docker Compose
- **Database**: PostgreSQL 16 (running in Docker with persistent volume)
- **Live Server IP**: `http://51.20.86.132:8080`
- **Currency**: Indian Rupee (`₹`)

---

## 🏛️ Project Architecture

```
Mini_Project/
├── backend/                               # Spring Boot 3.3.4 (Java 17)
│   ├── Dockerfile                         # Production-optimized Alpine JRE 17 container
│   ├── docker-compose.yml                 # Orchestrates Spring Boot API & PostgreSQL 16
│   ├── pom.xml                            # Dependencies (Spring Web, Security, JPA, OAuth2)
│   ├── src/main/java/com/campuscart/
│   │   ├── config/                        # SecurityConfig, CORS, DataInitializer (category seeder)
│   │   ├── controller/                    # Auth, Product, Category, User, Upload controllers
│   │   ├── dto/                           # Request & Response Data Transfer Objects
│   │   ├── entity/                        # User, Product, Category, ContactReveal, RefreshToken
│   │   ├── repository/                    # Spring Data JPA repositories
│   │   ├── security/                      # GoogleTokenVerifierService, JwtTokenProvider, JwtFilter
│   │   └── service/                       # AuthService, ProductService, CategoryService, UserService
│   └── src/main/resources/
│       └── application.yml                # Configured with environment variable fallbacks
└── frontend/                              # Flutter Mobile Application
    ├── android/                           # Android native configuration & manifests
    ├── lib/
    │   ├── constants/                     # AppColors, AppConstants (pointed to AWS EC2 IP)
    │   ├── models/                        # UserModel, ProductModel, CategoryModel
    │   ├── screens/                       # HomeFeed, ProductDetail, CreateListing, MyListings, Profile, Auth
    │   ├── services/                      # ApiService, AuthService, StorageService
    │   └── widgets/                       # ProductCard, CategoryPill, ContactBottomSheet, VerifiedBadge
    └── pubspec.yaml                       # Flutter dependencies (http, google_sign_in, image_picker)
```

---

## ✨ Features

- **🔐 Google Sign-In & JWT Authentication**: Sign in via Google OAuth2 or developer login. Secure JWT access tokens with 30-day refresh tokens.
- **🛍️ Browse & Filter Feed**: Real-time product search and category filtering (Textbooks, Electronics, Dorm, Lab Gear, Bikes & Mobility, Clothing).
- **📦 Clean Listing Creation**: Add title, pricing (in `₹`), item condition grade (`NEW`, `LIKE_NEW`, `GOOD`, `FAIR`), pickup spot, and photo attachments.
- **📞 On-Demand Contact Reveal**: Seller phone, WhatsApp, and email are hidden by default to prevent spam. Buyers tap **"Contact Seller"** to open direct Call and WhatsApp deep links.
- **🏷️ My Listings Management**: Track active listings, toggle status between `AVAILABLE` and `SOLD`, or delete sold items.
- **👤 Student Profile**: Manage contact info, preferred campus pickup location, and sign out securely.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Mobile App (Frontend)** | Flutter 3 (Dart), Material Design 3 |
| **Backend API** | Java 17, Spring Boot 3.3.4, Spring Security 6, Spring Data JPA |
| **Database** | PostgreSQL 16 (Dockerized container) |
| **Containerization** | Docker, Docker Compose |
| **Cloud Hosting** | AWS EC2 (Ubuntu 24.04 LTS) |
| **Networking** | RESTful JSON APIs, Stateless JWT, CORS enabled |

---

## 🐳 Running the Backend with Docker (Local or Cloud)

### 1. Build the Spring Boot JAR
From the `backend/` directory:
```powershell
mvn clean package -DskipTests
```
This produces `target/campus-cart-backend-1.0.0.jar`.

### 2. Start PostgreSQL & Spring Boot Together
```bash
docker compose up -d --build
```
Both the PostgreSQL database and Spring Boot backend will start. On startup, `DataInitializer.java` automatically seeds the default categories.

### 3. Verify Health
- Open in browser: `http://localhost:8080/api/v1/categories` (or `http://<EC2_PUBLIC_IP>:8080/api/v1/categories`)
- Check logs:
  ```bash
  docker compose logs -f backend
  ```

---

## ☁️ Deploying to AWS EC2

1. **Launch EC2 Instance**:
   - Instance Type: `t2.micro` or `t3.micro` (AWS Free Tier eligible)
   - OS: Ubuntu Server 24.04 LTS
   - Inbound Security Rules: SSH (`22`), HTTP (`80`), Custom TCP (`8080`).

2. **Connect via SSH**:
   ```powershell
   ssh -i "campuscart-key.pem" ubuntu@<YOUR_EC2_PUBLIC_IP>
   ```

3. **Install Docker & Enable Swap (prevents memory crash on 1GB RAM)**:
   ```bash
   sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
   echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
   sudo apt update && sudo apt install -y docker.io docker-compose-v2
   sudo systemctl enable --now docker
   sudo usermod -aG docker ubuntu
   newgrp docker
   ```

4. **Upload Backend & Pre-built JAR**:
   ```powershell
   cd backend
   scp -i "campuscart-key.pem" Dockerfile docker-compose.yml .dockerignore ubuntu@<YOUR_EC2_PUBLIC_IP>:~/backend/
   scp -i "campuscart-key.pem" target\campus-cart-backend-1.0.0.jar ubuntu@<YOUR_EC2_PUBLIC_IP>:~/backend/target/
   ```

5. **Run the Containers**:
   ```bash
   cd ~/backend
   docker compose up -d --build
   ```

---

## 📱 Compiling & Running the Flutter App

### 1. Run in Development Mode
Connect your Android phone via USB (or start an emulator) and run:
```powershell
cd frontend
flutter run
```

### 2. Build the Standalone Production APK
To generate a release APK that connects directly to the live AWS EC2 backend from anywhere in the world:
```powershell
cd frontend
flutter build apk --release
```

The resulting standalone APK is located at:
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```
This `.apk` file can be transferred and installed directly onto any Android device.

---

## 📡 API Reference

### 🔑 Authentication (`/api/v1/auth`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/auth/google` | Sign in with Google ID token | ❌ No |
| `POST` | `/api/v1/auth/refresh` | Refresh expired access token | ❌ No |
| `POST` | `/api/v1/auth/dev-login` | Instant demo login for local testing | ❌ No |

### 📂 Categories (`/api/v1/categories`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/categories` | Retrieve all product categories | ❌ No |

### 📦 Products (`/api/v1/products`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/products` | Browse & search listings (`query`, `categoryId`, `status`) | ❌ No |
| `GET` | `/api/v1/products/{id}` | Get listing details | ❌ No |
| `POST` | `/api/v1/products` | Create a new item listing | ✅ Yes |
| `PUT` | `/api/v1/products/{id}` | Update listing details | ✅ Yes (Seller) |
| `PATCH` | `/api/v1/products/{id}/status` | Update listing status (`AVAILABLE`, `SOLD`) | ✅ Yes (Seller) |
| `DELETE` | `/api/v1/products/{id}` | Delete listing | ✅ Yes (Seller) |
| `GET` | `/api/v1/products/my-listings` | Get current user's listings | ✅ Yes |
| `POST` | `/api/v1/products/{id}/reveal-contact` | Reveal seller contact info (Phone, WhatsApp, Meetup) | ✅ Yes |

### 📸 Media Uploads (`/api/v1/uploads`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `POST` | `/api/v1/uploads` | Upload listing photo (`multipart/form-data`) | ✅ Yes |
| `GET` | `/api/v1/uploads/{filename}` | Serve uploaded image | ❌ No |

### 👤 Profile (`/api/v1/users`)
| Method | Endpoint | Description | Auth Required |
|---|---|---|---|
| `GET` | `/api/v1/users/me` | Get current user's profile | ✅ Yes |
| `PUT` | `/api/v1/users/me` | Update contact phone, WhatsApp & dorm | ✅ Yes |

---

## 🔒 Security Best Practices Implemented

- **CORS Configured**: Strict origin headers allowing seamless mobile app access.
- **Stateless Sessions**: JWT bearer authentication with HMAC-SHA256 signature verification.
- **Privacy First**: Seller contact phone number and WhatsApp are shielded from public crawlers and unauthenticated visitors.
- **Memory Optimized**: JVM parameters tuned for free-tier cloud instances (`-Xmx350m -Xms200m`).
