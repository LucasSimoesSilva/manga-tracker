<h1 align="center" id="title">Manga Tracker</h1>  
  
<p id="description">A personal progressive web application (PWA) designed to track, manage, and update your manga reading progress in real-time, synchronized with Supabase.</p>  
</br>  
<h2>🧐 Features</h2>

* **Tab Navigation**: Group your mangas into 'Reading', 'Up to Date', and 'Completed' sections.
* **Smart Filtering**: Automatic transition between lists based on your reading progress.
* **MangaDex API Integration**: Search and retrieve metadata, status, and high-resolution covers.
* **Manual Overrides**: Edit both current and total chapters directly from the card.
* **Swipe to Delete**: Delete any manga from any list with a simple swipe gesture.
* **Reading URL**: Save and launch the external link of where you read each manga.
* **Email Caching**: Pre-fills the login screen with your last authenticated email.
* **Dark Theme**: Modern layout featuring a dark background with custom yellow details.

</br>  
  
<h2>💻 Built with</h2>  


*   Flutter SDK (Dart)
*   Supabase Database & Authentication
*   Netlify Hosting
  
</br>  
  
<h2>🚀 Mandatory Technologies to run</h2>  


- [Flutter SDK](https://docs.flutter.dev/get-started/install)  
- [Google Chrome](https://www.google.com/chrome/)  
  
</br>  
  
<h2>🛠️ How to use:</h2>  

- In the root of your project, create an `env.json` file:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_PUBLI_KEY": "sb_publishable_your_key"
}
```

In the terminal:

```code
Bash
```
---

# Clone the project  
```
$ git clone https://github.com/SEU_USUARIO/manga-tracker.git  
# Go to the project folder  
$ cd manga-tracker
$ flutter run -d chrome --dart-define-from-file=env.json
```
Or you can press F5 using VS Code with launch.json configured.