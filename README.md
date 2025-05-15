# Shopx 

Shopx is a modern, cross-platform e-commerce app built with Flutter. It provides a seamless shopping experience with features like product browsing, cart management, order history, and user authentication. Shopx is designed for Android, iOS, Web, Windows, macOS, and Linux.

## Features
- Browse products with images and details
- Add/remove products to/from cart
- Checkout with shipping address
- View order history and order details
- User authentication (login/signup)
- Responsive UI for mobile and desktop
- Persistent cart and order data

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart
- An editor like VS Code or Android Studio

### Setup
1. **Clone the repository:**
   ```sh
   git clone https://github.com/YOUR_USERNAME/project_x.git
   cd project_x
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Configure environment:**
   - Add your API keys and environment variables to a `.env` file if required.
   - (Optional) Set up Supabase or your backend as per `lib/core/supabase_config.dart`.

### Running the App
- **Android/iOS:**
  ```sh
  flutter run
  ```
- **Web:**
  ```sh
  flutter run -d chrome
  ```
- **Windows/macOS/Linux:**
  ```sh
  flutter run -d windows  # or macos/linux
  ```

## Folder Structure
```
lib/
  core/         # Core configs and utilities
  features/     # Feature modules (auth, cart, orders, products)
  pages/        # Main app pages
  screens/      # UI screens
  widgets/      # Reusable widgets
  theme/        # App theming
  routes/       # App routing
  assets/       # Images and static assets
```

## Contribution
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License.

---

**Shopx** – Your modern Flutter e-commerce solution!
