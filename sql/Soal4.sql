--============================================--
				--CASE 1--
--============================================--
-- Mencari total pendapatan dari setiap pengelompokan saluran untuk 5 negara dengan pendapatan tertinggi
-- Query ini digunakan untuk menganalisis data e-commerce
-- Tujuannya adalah untuk mengetahui total pendapatan transaksi dari setiap pengelompokan saluran
-- untuk lima negara dengan pendapatan tertinggi.
-- Memilih kolom channelGrouping dan country serta menghitung total pendapatan transaksi
-- untuk setiap kombinasi channelGrouping dan country.
SELECT 
    channelGrouping, 
    country, 
    SUM(totalTransactionRevenue) as total_revenue
FROM 
    ecommerce  -- Menentukan bahwa query akan dijalankan pada tabel ecommerce
GROUP BY 
    channelGrouping, 
    country  -- Mengelompokkan data berdasarkan channelGrouping dan country
ORDER BY 
    total_revenue
LIMIT 5;  -- Membatasi hasil hanya untuk lima baris pertama

--ini sangat berguna untuk memahami distribusi pendapatan berdasarkan saluran dan negara. Ini bisa membantu bisnis dalam membuat 
--keputusan strategis seperti di mana harus meningkatkan investasi pemasaran 
--atau di mana mereka mungkin perlu mengevaluasi kembali strategi mereka berdasarkan performa saluran di berbagai negara.

--============================================--
			     --=CASE 2=--
--============================================--
-- Menghitung metrik perilaku pengguna dan mengidentifikasi pengguna yang menghabiskan waktu di atas rata-rata di situs, tetapi melihat halaman lebih sedikit dari pengguna rata-rata
-- Mendefinisikan CTE (Common Table Expression) bernama user_behavior
-- CTE ini menghitung rata-rata timeOnSite, pageviews, dan sessionQualityDim untuk setiap fullVisitorId
WITH user_behavior AS (
    SELECT 
        fullVisitorId, 
        AVG(timeOnSite) as avg_timeOnSite,  -- Menghitung rata-rata timeOnSite untuk setiap fullVisitorId
        AVG(pageviews) as avg_pageviews,  -- Menghitung rata-rata pageviews untuk setiap fullVisitorId
        AVG(sessionQualityDim) as avg_sessionQualityDim  -- Menghitung rata-rata sessionQualityDim untuk setiap fullVisitorId
    FROM 
        ecommerce  -- Mengambil data dari tabel ecommerce
    GROUP BY 
        fullVisitorId  -- Mengelompokkan data berdasarkan fullVisitorId
)

-- Query utama memilih fullVisitorId dari CTE user_behavior
-- Hanya fullVisitorId di mana avg_timeOnSite lebih besar dari rata-rata avg_timeOnSite untuk semua pengguna
-- dan avg_pageviews lebih kecil dari rata-rata avg_pageviews untuk semua pengguna yang dipilih
SELECT 
    fullVisitorId
FROM 
    user_behavior
WHERE 
    avg_timeOnSite > (SELECT AVG(avg_timeOnSite) FROM user_behavior)  -- Memfilter pengguna yang memiliki avg_timeOnSite lebih besar dari rata-rata
    AND avg_pageviews < (SELECT AVG(avg_pageviews) FROM user_behavior);  -- dan avg_pageviews lebih kecil dari rata-rata
    
 --dapat digunakan untuk mengidentifikasi pengguna yang menghabiskan lebih banyak waktu di situs (dibandingkan dengan rata-rata pengguna) 
 --tetapi melihat lebih sedikit halaman (juga dibandingkan dengan rata-rata pengguna). Ini bisa menjadi indikasi bahwa pengguna tersebut 
 --menemukan konten di situs yang menarik dan menghabiskan banyak waktu untuk membacanya, tetapi mereka mungkin mengalami kesulitan dalam menavigasi situs atau menemukan halaman lain yang relevan. 
 --hasil dari query ini dapat digunakan untuk menginformasikan upaya optimasi situs web atau strategi konten.

--============================================--
			     --=CASE 3=--
--============================================--

-- Menghitung kinerja setiap produk dan menandai produk dengan jumlah pengembalian dana yang melebihi 10% dari total pendapatannya
-- Mendefinisikan CTE (Common Table Expression) bernama product_performance
-- CTE ini menghitung total totalTransactionRevenue, productQuantity, dan productRefundAmount untuk setiap v2ProductName
WITH product_performance AS (
    SELECT 
        v2ProductName, 
        SUM(totalTransactionRevenue) as total_revenue,  -- Menghitung total totalTransactionRevenue untuk setiap v2ProductName
        SUM(productQuantity) as total_quantity,  -- Menghitung total productQuantity untuk setiap v2ProductName
        SUM(productRefundAmount) as total_refund  -- Menghitung total productRefundAmount untuk setiap v2ProductName
    FROM 
        ecommerce  -- Mengambil data dari tabel ecommerce
    GROUP BY 
        v2ProductName  -- Mengelompokkan data berdasarkan v2ProductName
), 

-- Mendefinisikan CTE kedua bernama product_ranking
-- CTE ini menghitung net_revenue (yaitu, total pendapatan dikurangi total pengembalian dana) dan peringkat pendapatan bersih untuk setiap produk
product_ranking AS (
    SELECT 
        v2ProductName, 
        total_revenue, 
        total_quantity, 
        total_refund, 
        (total_revenue - total_refund) as net_revenue,  -- Menghitung net_revenue
        RANK() OVER (ORDER BY (total_revenue - total_refund) DESC) as revenue_rank  -- Menghitung peringkat pendapatan bersih
    FROM 
        product_performance
)

-- Query utama memilih beberapa kolom dari CTE product_ranking
-- dan juga menambahkan kolom baru refund_flag yang menunjukkan apakah total pengembalian dana untuk produk tersebut lebih besar dari 10% dari total pendapatan
SELECT 
    v2ProductName, 
    total_revenue, 
    total_quantity, 
    total_refund, 
    net_revenue, 
    revenue_rank, 
    CASE 
        WHEN total_refund > total_revenue * 0.1 THEN 'Yes'  -- Jika total pengembalian dana lebih besar dari 10% dari total pendapatan, refund_flag adalah 'Yes'
        ELSE 'No'  -- Jika tidak, refund_flag adalah 'No'
    END as refund_flag
FROM 
    product_ranking;
    
--query ini dapat digunakan untuk menganalisis kinerja produk berdasarkan pendapatan, kuantitas, dan pengembalian dana. 
--Hasil dari query ini dapat digunakan untuk mengidentifikasi produk yang menghasilkan pendapatan bersih tertinggi, 
--serta produk yang mungkin memiliki masalah dengan pengembalian dana yang tinggi.

