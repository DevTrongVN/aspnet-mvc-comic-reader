# 📚 Comic Reading Website

> A full-featured comic reading web application built with ASP.NET MVC and SQL Server.

## 📖 Overview

This project is a comic reading website that allows users to browse, read, and interact with comics. It simulates a real-world system with both user-side features and an admin management panel, focusing on backend logic, database handling, and MVC architecture.

---

## ✨ Features

### 👤 User Features
* **Account Management:** Register / Login / Logout
* **Interaction:** Comment on comics & chapters, rate comics (star system)
* **Personalization:** Track reading history, follow / unfollow comics

### 🔍 Search & Filter
* Search by **comic name** or **author**
* Filter by **genre**

### 📖 Reading Experience
* Image-based chapter reading
* Seamless chapter navigation (next / previous)
* Auto-save reading history

### ⚙️ Admin Panel
* **Content Management:** Add / Edit / Delete comics, upload covers & chapter images
* **Metadata Management:** Manage genres & authors dynamically
* **Chapter Management:** Add and organize chapters dynamically

---

## 🛠️ Technologies Used

* **Backend:** ASP.NET MVC (C#), LINQ to SQL
* **Database:** SQL Server
* **Frontend:** HTML / CSS / JavaScript
* **Auth:** Session-based Authentication

---

## 📂 Project Structure

```text
WebTruyenTranh/
├── Controllers/
│   ├── HomeController.cs
│   └── AdminController.cs
├── Models/
│   ├── Truyen.cs
│   ├── BinhLuanContainer.cs
├── Views/
│   ├── Home/
│   ├── Admin/
│   └── Shared/
└── Content/
    ├── AnhBia/
    └── ChapTruyen/
```


---

## ⚙️ Setup Instructions (Run Locally)

### 1. Clone project
```bash
git clone https://github.com/DevTrongVN/comic-reader-website
```
## 2. Open project
Open with Visual Studio
Build solution
## 3. Setup Database
Open SQL Server Management Studio
Create or restore database: WebDocTruyen
Import data if you have .sql file
## 4. Configure connection string

Open Web.config and set:

Data Source=.;Initial Catalog=WebDocTruyen;Trusted_Connection=True;
## 5. Run project
Press F5 or click Start
Web will run on local server (IIS Express)
## 📸 Demo
* Home page
<img width="1919" height="1015" alt="Ảnh chụp màn hình 2026-04-28 223332" src="https://github.com/user-attachments/assets/9812d7a0-ba7d-40f6-b484-cd0dd1e3bcad" />
* Comic detail page
<img width="1919" height="1019" alt="Ảnh chụp màn hình 2026-04-28 223338" src="https://github.com/user-attachments/assets/eb8e84eb-1980-42a2-9760-54f05c60450b" />
*  Reading page
<img width="1916" height="1012" alt="Ảnh chụp màn hình 2026-04-28 223348" src="https://github.com/user-attachments/assets/e01c32e5-f77c-4ea0-ad33-3b93372ff655" />
* Admin dashboard
<img width="1919" height="1018" alt="Ảnh chụp màn hình 2026-04-28 223758" src="https://github.com/user-attachments/assets/c5508889-a57a-414a-a3c2-373128e2aa69" />
* follow page
<img width="1919" height="1022" alt="Ảnh chụp màn hình 2026-04-28 223824" src="https://github.com/user-attachments/assets/d5eae9c1-638b-4973-9e85-d70a2a08870d" />
* History page
<img width="1919" height="1015" alt="Ảnh chụp màn hình 2026-04-28 223818" src="https://github.com/user-attachments/assets/65bfdde1-796e-45df-8948-c32c13287d79" />
* sign up
<img width="1919" height="1021" alt="Ảnh chụp màn hình 2026-04-28 223430" src="https://github.com/user-attachments/assets/7daed39b-1ed1-4743-afca-135d5a9cb452" />
* sign in
<img width="1919" height="1015" alt="Ảnh chụp màn hình 2026-04-28 223748" src="https://github.com/user-attachments/assets/1b0127e8-f95e-43b1-85c5-033f81f2adf8" />
* search advance
<img width="1919" height="1019" alt="Ảnh chụp màn hình 2026-04-28 223853" src="https://github.com/user-attachments/assets/e4e05099-ea5f-4a9c-a517-c5c4800053f4" />

##🎯 Future Improvements
Improve UI/UX design
Add REST API
Separate frontend & backend
Add AI recommendation system
Dark mode
## 👨‍💻 Author
GitHub: https://github.com/DevTrongVN
## ⭐ Notes

This project demonstrates:

Fullstack development (ASP.NET MVC + SQL Server)
Database relationships and data handling
Real-world feature implementation
MVC architecture design
