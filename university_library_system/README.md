Check Yourself
1. What is the difference between the Model, View, and ViewModel in this application?
> Model tugasnya buat menyimpan data mentah (Book & Loan), ViewModel tugasnya buat mengelola state dan mengeksekusi logika keputusan buat diberi tahu ke View, sedangkan View gunanya hanya untuk menampilkan tampilan berdasarkan data dari ViewModel.

2. What should happen if a student attempts to borrow a book that already has an active loan?
> Peminjaman akan langsung ditolak oleh ViewModel dan aplikasi akan menampilkan pesan peringatan bahwa buku tersebut sudah dipinjam.

3. Why is it better to calculate the fine in one place rather than repeating the formula in multiple widgets?
> logika denda dipusatkan di satu tempat supaya mencegah dari bug karena perbedaan rumus di masing-masing widget dan mencegah duplikasi kode dan supaya gampang kalau ada aturan yang berubah.

4. What is the difference between a book being Overdue and being Missing?
> Perbedaannya status buku jadi overdue kalau pengembalian buku melewati jatuh tempo (di bawah 6 bulan) dan denda tiap hari terus berjalan, sedangkan kalau status Missing berlaku setelah peminjaman buku melewati batas 6 bulan dimana user harus membayar akumulasi denda + harga buku sebagai konsekuensi.

5. If the university changes its weekly fine from Rp5,000 to Rp7,000, how should the app be updated?
> Perubahan tarif denda cukup dilakukan dengan memperbarui nilai konstanta fineStep dari 5000 menjadi 7000 di dalam file FinePolicy tanpa perlu mengubah kode pada View atau ViewModel.