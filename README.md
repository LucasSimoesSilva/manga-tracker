# Manga Tracker

A personal progressive web application (PWA) designed to track, manage, and update your manga reading progress in real-time.

## Features

* **Tab Navigation**: Group your mangas into 'Reading', 'Up to Date', and 'Completed' sections.
* **Smart Filtering**: Automatic transition between lists based on your reading progress.
* **MangaDex Integration**: Search and retrieve metadata, status, and high-resolution covers.
* **Manual Overrides**: Edit both current and total chapters directly from the UI.
* **Secure Database Sync**: Real-time cloud persistence powered by Supabase.
* **Swipe to Delete**: Delete any manga from any list with a simple swipe gesture.
* **Reading URL**: Save and launch the external link of where you read each manga.
* **Email Caching**: Pre-fills the login screen with your last authenticated email.

## Tech Stack

* **Frontend**: Flutter Web (PWA)
* **Backend & Database**: Supabase
* **Hosting**: Netlify

## Environment Variables

The project relies on a secure build-time configuration file. Create an `env.json` file in the root directory (make sure it is added to your `.gitignore`):

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLI_KEY": "sb_publishable_your_key"
}
```

## How to Run Locally

You can use the flutter command line:

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

or run in your favorite IDE.

## Deployment

To compile a production-ready web bundle:

```bash
flutter build web --dart-define-from-file=env.json
```

Upload the generated build/web folder to Netlify.