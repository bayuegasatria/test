-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 14, 2025 at 04:30 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bmn`
--

-- --------------------------------------------------------

--
-- Table structure for table `aduan`
--

CREATE TABLE `aduan` (
  `id` int(11) NOT NULL,
  `no_aduan` varchar(50) NOT NULL,
  `tanggal` date NOT NULL,
  `aduan_status` enum('Belum Diproses','Sedang Diproses','Selesai Diproses','Dihapus') DEFAULT 'Belum Diproses',
  `pegawai_id` bigint(20) UNSIGNED NOT NULL,
  `divisi_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `inventaris_id` bigint(20) UNSIGNED DEFAULT NULL,
  `problem` varchar(250) DEFAULT NULL,
  `petugas_id` int(11) DEFAULT NULL,
  `analisa` varchar(250) DEFAULT NULL,
  `follow_up` varchar(250) DEFAULT NULL,
  `result` varchar(250) DEFAULT NULL,
  `analyze_date` date DEFAULT NULL,
  `teamleader_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `aduantik`
--

CREATE TABLE `aduantik` (
  `id` int(11) NOT NULL,
  `no_aduan` varchar(50) NOT NULL DEFAULT '',
  `tanggal` date NOT NULL,
  `users_id` bigint(20) UNSIGNED NOT NULL,
  `divisi_id` bigint(20) UNSIGNED NOT NULL,
  `itasset_id` bigint(20) UNSIGNED NOT NULL,
  `trouble` varchar(250) NOT NULL DEFAULT '',
  `follow_up` varchar(250) NOT NULL DEFAULT '',
  `result` varchar(250) NOT NULL DEFAULT '',
  `analyze_date` date NOT NULL,
  `status` enum('Belum Diproses','Sedang Diproses','Selesai Diproses','Dihapus') NOT NULL DEFAULT 'Belum Diproses',
  `petugas_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `analisa` varchar(250) DEFAULT NULL,
  `followup_date` date DEFAULT NULL,
  `result_date` date DEFAULT NULL,
  `perkap_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `broken`
--

CREATE TABLE `broken` (
  `id` int(11) NOT NULL,
  `nomor` varchar(25) NOT NULL DEFAULT '',
  `users_id` int(11) NOT NULL,
  `pejabat_id` int(11) NOT NULL,
  `labory_id` int(11) NOT NULL,
  `inventaris_id` int(11) NOT NULL,
  `tanggal` date NOT NULL,
  `jumlah` int(11) NOT NULL,
  `ket` varchar(255) DEFAULT NULL,
  `foto` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `mengetahui` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `brokenbmn`
--

CREATE TABLE `brokenbmn` (
  `id` int(11) NOT NULL,
  `nomor` varchar(50) NOT NULL,
  `tanggal` date NOT NULL,
  `users_id` int(11) NOT NULL DEFAULT 0,
  `divisi_id` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `jenis_ba` enum('B','R') DEFAULT 'R'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `car`
--

CREATE TABLE `car` (
  `id` int(11) NOT NULL,
  `type` enum('C','M') NOT NULL DEFAULT 'C' COMMENT '''C'' = CAR, ''M''=MOTORCYCLE',
  `code` varchar(50) NOT NULL,
  `merk` varchar(50) NOT NULL,
  `police_number` varchar(50) NOT NULL,
  `tax_date` date DEFAULT NULL,
  `police_number_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `operasional` enum('Y','N') DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `divisi`
--

CREATE TABLE `divisi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama` varchar(255) NOT NULL,
  `lokasi` varchar(255) NOT NULL,
  `kode_sppd` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `driver`
--

CREATE TABLE `driver` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `aktif` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventaris`
--

CREATE TABLE `inventaris` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama_barang` varchar(255) NOT NULL,
  `kode_barang` varchar(50) DEFAULT NULL,
  `harga` int(11) DEFAULT 0,
  `kode_bmn` varchar(255) DEFAULT NULL,
  `jenis_barang` bigint(20) UNSIGNED DEFAULT NULL,
  `jumlah_barang` int(11) DEFAULT 0,
  `satuan_id` int(11) NOT NULL DEFAULT 0,
  `tanggal_diterima` date DEFAULT NULL,
  `merk` varchar(255) DEFAULT NULL,
  `no_seri` varchar(255) DEFAULT NULL,
  `lokasi` bigint(20) UNSIGNED DEFAULT NULL,
  `penanggung_jawab` bigint(20) UNSIGNED DEFAULT 0,
  `file_user_manual` varchar(255) DEFAULT NULL,
  `file_trouble` varchar(255) DEFAULT NULL,
  `file_ika` varchar(255) DEFAULT NULL,
  `file_foto` varchar(255) DEFAULT NULL,
  `status_barang` enum('baik','rusak') DEFAULT 'baik',
  `spesifikasi` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `kind` enum('D','R','L') DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `link_video` varchar(150) DEFAULT NULL,
  `file_sert` varchar(150) DEFAULT NULL,
  `sinonim` varchar(200) DEFAULT NULL,
  `file_evakali` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `itasset`
--

CREATE TABLE `itasset` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `kode_barang` varchar(50) DEFAULT NULL,
  `nama_barang` varchar(255) NOT NULL,
  `jenistik_id` int(11) DEFAULT NULL,
  `lokasi` varchar(50) NOT NULL,
  `users_id` bigint(20) UNSIGNED DEFAULT NULL,
  `spesifikasi` text DEFAULT NULL,
  `file_foto` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- Table structure for table `jabatan`
--

CREATE TABLE `jabatan` (
  `id` int(11) NOT NULL,
  `jabatan` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT '2000-01-01 00:00:00',
  `urutan` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jenistik`
--

CREATE TABLE `jenistik` (
  `id` int(11) NOT NULL,
  `kelompok` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jenis_barang`
--

CREATE TABLE `jenis_barang` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama` varchar(50) DEFAULT NULL,
  `kelompok` varchar(1) NOT NULL,
  `aktif` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lokasi`
--

CREATE TABLE `lokasi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama` varchar(50) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id` int(11) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `pengajuan_id` int(11) DEFAULT NULL,
  `judul` varchar(255) NOT NULL,
  `pesan` varchar(255) DEFAULT NULL,
  `is_read` enum('Y','N') DEFAULT 'N',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengajuan`
--

CREATE TABLE `pengajuan` (
  `id` int(11) NOT NULL,
  `id_user` bigint(20) UNSIGNED NOT NULL,
  `no_pengajuan` varchar(50) NOT NULL,
  `tujuan` varchar(250) NOT NULL,
  `jenis_kendaraan` enum('C','M') NOT NULL DEFAULT 'C',
  `perlu_supir` enum('Y','N') DEFAULT 'N',
  `pengemudi` varchar(50) DEFAULT NULL,
  `tanggal_berangkat` datetime NOT NULL,
  `tanggal_kembali` datetime NOT NULL,
  `jumlah_pengguna` int(11) DEFAULT 0,
  `keterangan` varchar(255) DEFAULT NULL,
  `catatan` varchar(255) DEFAULT NULL,
  `file_path` varchar(250) DEFAULT NULL,
  `file_name` varchar(250) DEFAULT NULL,
  `status` enum('P','Y','N','C') DEFAULT 'P'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `perpindahan_dbr`
--

CREATE TABLE `perpindahan_dbr` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `no` varchar(50) NOT NULL,
  `pelapor_id` bigint(20) UNSIGNED NOT NULL,
  `tanggal` date NOT NULL,
  `inventaris_id` bigint(20) UNSIGNED DEFAULT NULL,
  `old_lokasi` bigint(20) UNSIGNED DEFAULT NULL,
  `new_lokasi` bigint(20) UNSIGNED DEFAULT NULL,
  `keterangan` varchar(250) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `petugas`
--

CREATE TABLE `petugas` (
  `id` int(11) NOT NULL,
  `jenis` varchar(50) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pindahtangan`
--

CREATE TABLE `pindahtangan` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nomor` varchar(50) NOT NULL,
  `tanggal` date NOT NULL,
  `kelompok` varchar(50) NOT NULL,
  `inventaris_id` bigint(20) UNSIGNED DEFAULT NULL,
  `asal_id` bigint(20) UNSIGNED DEFAULT NULL,
  `baru_id` bigint(20) UNSIGNED DEFAULT NULL,
  `alamat_lama` varchar(50) DEFAULT NULL,
  `alamat_baru` varchar(50) DEFAULT NULL,
  `ket` varchar(150) NOT NULL,
  `lokasi_baru` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pinjam`
--

CREATE TABLE `pinjam` (
  `id` int(11) NOT NULL,
  `id_pengajuan` int(11) NOT NULL,
  `tanggal_pengembalian` datetime DEFAULT NULL,
  `id_kendaraan` int(11) NOT NULL,
  `km_awal` varchar(20) NOT NULL DEFAULT '0',
  `awal_path` varchar(250) DEFAULT NULL,
  `awal_name` varchar(250) DEFAULT NULL,
  `km_akhir` varchar(20) NOT NULL DEFAULT '0',
  `akhir_path` varchar(250) DEFAULT NULL,
  `akhir_name` varchar(250) DEFAULT NULL,
  `id_supir` int(11) DEFAULT NULL,
  `status` enum('berjalan','selesai','menunggu','batal') DEFAULT 'berjalan'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teamleader`
--

CREATE TABLE `teamleader` (
  `id` int(11) NOT NULL,
  `users_id` bigint(20) UNSIGNED DEFAULT NULL,
  `divisi_id` bigint(20) UNSIGNED DEFAULT NULL,
  `detail` varchar(150) DEFAULT NULL,
  `aktif` enum('Y','N') DEFAULT 'Y',
  `datefrom` date DEFAULT NULL,
  `dateto` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `no_pegawai` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `tempat_lhr` varchar(255) DEFAULT NULL,
  `tgl_lhr` date NOT NULL,
  `alamat` text DEFAULT NULL,
  `nikah` enum('Y','N') DEFAULT NULL,
  `jkel` enum('P','L') DEFAULT NULL,
  `telp` varchar(13) DEFAULT NULL,
  `jabatan_id` int(11) NOT NULL DEFAULT 0,
  `jabasn_id` int(11) DEFAULT 0,
  `seri_karpeg` varchar(50) DEFAULT NULL,
  `status` varchar(13) NOT NULL,
  `divisi_id` int(11) NOT NULL,
  `subdivisi_id` int(11) DEFAULT NULL,
  `golongan_id` int(11) DEFAULT NULL,
  `foto` varchar(100) DEFAULT '',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `aktif` enum('Y','N') DEFAULT NULL,
  `deskjob` varchar(250) NOT NULL,
  `TMT_Capeg` date DEFAULT NULL,
  `namanogelar` varchar(250) DEFAULT NULL,
  `agama` varchar(50) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_token`
--

CREATE TABLE `user_token` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `app_id` varchar(250) NOT NULL,
  `fcm_token` text DEFAULT NULL,
  `login` enum('Y','N') NOT NULL DEFAULT 'N',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `aduan`
--
ALTER TABLE `aduan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_aduan_pegawai` (`pegawai_id`),
  ADD KEY `fk_aduan_divisi` (`divisi_id`),
  ADD KEY `fk_aduan_inventaris` (`inventaris_id`),
  ADD KEY `fk_aduan_teamleader` (`teamleader_id`),
  ADD KEY `fk_aduan_petugas` (`petugas_id`);

--
-- Indexes for table `aduantik`
--
ALTER TABLE `aduantik`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_aduantik_users` (`users_id`),
  ADD KEY `fk_aduantik_divisi` (`divisi_id`),
  ADD KEY `fk_aduantik_itasset` (`itasset_id`),
  ADD KEY `fk_aduantik_petugas` (`petugas_id`);

--
-- Indexes for table `broken`
--
ALTER TABLE `broken`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `brokenbmn`
--
ALTER TABLE `brokenbmn`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `car`
--
ALTER TABLE `car`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `divisi`
--
ALTER TABLE `divisi`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `driver`
--
ALTER TABLE `driver`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `inventaris`
--
ALTER TABLE `inventaris`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `kode_barang` (`kode_barang`),
  ADD KEY `fk_inventaris_lokasi` (`lokasi`),
  ADD KEY `fk_inventaris_jenis_barang` (`jenis_barang`),
  ADD KEY `fk_inventaris_penanggung_jawab` (`penanggung_jawab`);

--
-- Indexes for table `itasset`
--
ALTER TABLE `itasset`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_itasset_jenistik` (`jenistik_id`),
  ADD KEY `fk_itasset_users` (`users_id`);

--
-- Indexes for table `jabatan`
--
ALTER TABLE `jabatan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jenistik`
--
ALTER TABLE `jenistik`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jenis_barang`
--
ALTER TABLE `jenis_barang`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `lokasi`
--
ALTER TABLE `lokasi`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `pengajuan_id` (`pengajuan_id`);

--
-- Indexes for table `pengajuan`
--
ALTER TABLE `pengajuan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_vrent_user` (`id_user`);

--
-- Indexes for table `perpindahan_dbr`
--
ALTER TABLE `perpindahan_dbr`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_no_dbr` (`no`),
  ADD KEY `fk_dbr_pelapor` (`pelapor_id`),
  ADD KEY `fk_dbr_inventaris` (`inventaris_id`),
  ADD KEY `fk_dbr_old_lokasi` (`old_lokasi`),
  ADD KEY `fk_dbr_new_lokasi` (`new_lokasi`);

--
-- Indexes for table `petugas`
--
ALTER TABLE `petugas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `pindahtangan`
--
ALTER TABLE `pindahtangan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pindahtangan_inventaris` (`inventaris_id`),
  ADD KEY `fk_pindahtangan_asal` (`asal_id`),
  ADD KEY `fk_pindahtangan_baru` (`baru_id`),
  ADD KEY `fk_pindahtangan_lokasi` (`lokasi_baru`);

--
-- Indexes for table `pinjam`
--
ALTER TABLE `pinjam`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pinjam_pengajuan` (`id_pengajuan`),
  ADD KEY `fk_pinjam_car` (`id_kendaraan`),
  ADD KEY `fk_pinjam_driver` (`id_supir`);

--
-- Indexes for table `teamleader`
--
ALTER TABLE `teamleader`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_teamleader_user` (`users_id`),
  ADD KEY `fk_teamleader_divisi` (`divisi_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user_token`
--
ALTER TABLE `user_token`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_token_user` (`user_id`),
  ADD KEY `user_id` (`user_id`,`app_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aduan`
--
ALTER TABLE `aduan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `aduantik`
--
ALTER TABLE `aduantik`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `broken`
--
ALTER TABLE `broken`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `brokenbmn`
--
ALTER TABLE `brokenbmn`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `car`
--
ALTER TABLE `car`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `divisi`
--
ALTER TABLE `divisi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `driver`
--
ALTER TABLE `driver`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventaris`
--
ALTER TABLE `inventaris`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `itasset`
--
ALTER TABLE `itasset`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jabatan`
--
ALTER TABLE `jabatan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jenistik`
--
ALTER TABLE `jenistik`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jenis_barang`
--
ALTER TABLE `jenis_barang`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lokasi`
--
ALTER TABLE `lokasi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pengajuan`
--
ALTER TABLE `pengajuan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `perpindahan_dbr`
--
ALTER TABLE `perpindahan_dbr`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `petugas`
--
ALTER TABLE `petugas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pindahtangan`
--
ALTER TABLE `pindahtangan`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pinjam`
--
ALTER TABLE `pinjam`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teamleader`
--
ALTER TABLE `teamleader`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_token`
--
ALTER TABLE `user_token`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `aduan`
--
ALTER TABLE `aduan`
  ADD CONSTRAINT `fk_aduan_divisi` FOREIGN KEY (`divisi_id`) REFERENCES `divisi` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduan_inventaris` FOREIGN KEY (`inventaris_id`) REFERENCES `inventaris` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduan_pegawai` FOREIGN KEY (`pegawai_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduan_petugas` FOREIGN KEY (`petugas_id`) REFERENCES `petugas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduan_teamleader` FOREIGN KEY (`teamleader_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `aduantik`
--
ALTER TABLE `aduantik`
  ADD CONSTRAINT `fk_aduantik_divisi` FOREIGN KEY (`divisi_id`) REFERENCES `divisi` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduantik_itasset` FOREIGN KEY (`itasset_id`) REFERENCES `itasset` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduantik_petugas` FOREIGN KEY (`petugas_id`) REFERENCES `petugas` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aduantik_users` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `inventaris`
--
ALTER TABLE `inventaris`
  ADD CONSTRAINT `fk_inventaris_jenis_barang` FOREIGN KEY (`jenis_barang`) REFERENCES `jenis_barang` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventaris_lokasi` FOREIGN KEY (`lokasi`) REFERENCES `lokasi` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventaris_penanggung_jawab` FOREIGN KEY (`penanggung_jawab`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `itasset`
--
ALTER TABLE `itasset`
  ADD CONSTRAINT `fk_itasset_jenistik` FOREIGN KEY (`jenistik_id`) REFERENCES `jenistik` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_itasset_users` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `notifikasi_ibfk_2` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan` (`id`);

--
-- Constraints for table `pengajuan`
--
ALTER TABLE `pengajuan`
  ADD CONSTRAINT `fk_vrent_user` FOREIGN KEY (`id_user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `perpindahan_dbr`
--
ALTER TABLE `perpindahan_dbr`
  ADD CONSTRAINT `fk_dbr_inventaris` FOREIGN KEY (`inventaris_id`) REFERENCES `inventaris` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dbr_new_lokasi` FOREIGN KEY (`new_lokasi`) REFERENCES `lokasi` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dbr_old_lokasi` FOREIGN KEY (`old_lokasi`) REFERENCES `lokasi` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_dbr_pelapor` FOREIGN KEY (`pelapor_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE;

--
-- Constraints for table `petugas`
--
ALTER TABLE `petugas`
  ADD CONSTRAINT `petugas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `pindahtangan`
--
ALTER TABLE `pindahtangan`
  ADD CONSTRAINT `fk_pindahtangan_asal` FOREIGN KEY (`asal_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pindahtangan_baru` FOREIGN KEY (`baru_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pindahtangan_inventaris` FOREIGN KEY (`inventaris_id`) REFERENCES `inventaris` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pindahtangan_lokasi` FOREIGN KEY (`lokasi_baru`) REFERENCES `lokasi` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `pinjam`
--
ALTER TABLE `pinjam`
  ADD CONSTRAINT `fk_pinjam_car` FOREIGN KEY (`id_kendaraan`) REFERENCES `car` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pinjam_driver` FOREIGN KEY (`id_supir`) REFERENCES `driver` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pinjam_pengajuan` FOREIGN KEY (`id_pengajuan`) REFERENCES `pengajuan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `teamleader`
--
ALTER TABLE `teamleader`
  ADD CONSTRAINT `fk_teamleader_divisi` FOREIGN KEY (`divisi_id`) REFERENCES `divisi` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_teamleader_user` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `user_token`
--
ALTER TABLE `user_token`
  ADD CONSTRAINT `fk_user_token_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
