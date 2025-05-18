# Shopx

Shopx is a modern, cross-platform e-commerce app built with Flutter. It provides a seamless shopping experience with features like product browsing, cart management, order history, user authentication, and an AI-powered shopping assistant chatbot. Shopx is designed for Android, iOS, Web, Windows, macOS, and Linux.

---

## Features

- **Product Browsing:** View products with images, details, and categories.
- **Cart Management:** Add, remove, and update products in your cart.
- **Checkout:** Place orders with shipping address management.
- **Order History:** View past orders and order details.
- **User Authentication:** Secure login and signup.
- **AI Chatbot:** Get shopping assistance via an integrated AI chatbot (OpenAI).
- **Theme Support:** Toggle between dark and light mode.
- **Responsive UI:** Optimized for mobile and desktop.
- **Persistent Data:** Cart and order data are saved across sessions.

---

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
   - Create a `.env` file in the project root:
     ```
     # Supabase Configuration
     SUPABASE_URL=your_supabase_url_here
     SUPABASE_ANON_KEY=your_supabase_anon_key_here

     # OpenAI Configuration
     OPENAI_API_KEY=your_openai_api_key_here
     ```
   - Do **not** commit your `.env` file. Use `.env.example` for reference.

4. **(Optional) Set up Supabase or your backend as per `lib/core/supabase_config.dart`.**

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

---
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
