# chat_app

A new Flutter project following professional coding style


## Project Structure

This project follows a structured and modular approach to keep the codebase clean and maintainable. Below is an overview of the project architecture:

- **lib/constants**: Contains necessary constants used throughout the app. Centralizing constants helps in maintaining consistency and makes it easier to manage values that are used in multiple places.

- **lib/models**: Contains class models for type safety when using Firebase. Using models ensures that the data handled in the app is type-safe, reducing errors and improving code readability.

- **lib/services**: Contains all types of backend services. This separation allows for a clear distinction between the app's frontend and backend logic, making the code more modular and easier to maintain.

- **lib/utils**: Contains all the pages except `main.dart`, which is directly under `lib/`. Organizing pages in a separate folder helps in managing the app's navigation and UI components more effectively.

- **lib/widgets**: Contains various widgets used in the app. Reusable widgets promote code reuse and help in maintaining a consistent look and feel across the app.

## Live Demo

Watch a demo of the app on YouTube:
[Demo Video](https://www.youtube.com/watch?v=eClsbP6L1Ic)

- **0 to 1:03 minute**: Signup and logout functionality.
- **1:04 to 2:00 minutes**: Login and users list.
- **2:01 to 3:58 minutes**: Real-time chat with text and image as the message.
- **4:00 to end**: Push notification when logged out.

## Release APK

Download the release APK file:
[Release APK](Released-Apk/)

## Architecture Overview

This Flutter project adopts a modular and organized architecture, which brings several benefits:

1. **Separation of Concerns**: By dividing the project into different folders based on functionality, we ensure that each part of the app is responsible for a specific aspect. This makes the code easier to manage and understand.

2. **Reusability**: Placing widgets in a dedicated folder allows for easy reuse across different parts of the app, promoting DRY (Don't Repeat Yourself) principles.

3. **Type Safety**: Using models for Firebase interactions ensures that the data structures are well-defined and type-safe, reducing runtime errors and making the code more robust.

4. **Scalability**: The modular structure makes it easier to scale the app. New features can be added with minimal impact on the existing codebase.

5. **Maintainability**: Clear separation of constants, services, and UI components improves maintainability. Each part of the app can be modified independently, making the development process more efficient.

This architecture is designed to support a clean and maintainable codebase, facilitating collaboration and long-term project health.

For more detailed information on Flutter best practices and advanced topics, refer to the [Flutter documentation](https://docs.flutter.dev/).
