-- 1. Selama transaksi yang terjadi selama 2021, pada bulan apa total nilai transaksi (after_discount) paling besar? Gunakan is_valid = 1 untuk memfilter data transaksi.
select 
	monthname(order_date) as bulan, 					
	round(sum(after_discount)) as transaksi_terbesar	
from order_detail										
where 
	extract(year from order_date) = 2021				
	and is_valid = 1									
group by  
	bulan											
order by 
	transaksi_terbesar desc						
limit 5;			

-- 2. Selama transaksi pada tahun 2022, kategori apa yang menghasilkan nilai transaksi paling besar?. Gunakan is_valid = 1 untuk memfilter data transaksi.
select
	year(order_date) as tahun,
    s.category,
    round(sum(after_discount)) as total_transaksi
from 
	order_detail as o
left join sku_detail as s on o.sku_id = s.id
where
	extract(year from o.order_date) =2022
    and is_valid=1
group by 
	s.category, 
    tahun
order by 
	total_transaksi desc
limit 5;

-- 3. Bandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022. Sebutkan kategori apa saja yang mengalami peningkatan dan kategori apa yang mengalami penurunan nilai transaksi dari tahun 2021 ke 2022. Gunakan is_valid = 1 untuk memfilter data transaksi.
with transaksi2021 as (
select
	year(od.order_date) as tahun,
    category,
    round(sum(after_discount)) total_transaksi2021
from 
	order_detail as od
left join sku_detail as sd on od.sku_id = sd.id
where 
	year(order_date) = 2021 
	and is_valid = 1
group by 
	category, 
	tahun
order by 
	total_transaksi2021
)
, transaksi2022 as (
select
	year(od.order_date) as tahun,
    category,
    round(sum(after_discount)) total_transaksi2022
from 
	order_detail as od
left join sku_detail as sd on od.sku_id = sd.id
where 
	year(order_date) = 2022 
    and is_valid = 1
group by 
	category, 
    tahun
order by 
	total_transaksi2022
)
select 
	transaksi2021.category,
    total_transaksi2021,
	total_transaksi2022,
    round(((total_transaksi2022 - total_transaksi2021)/total_transaksi2021)*100) as grow,
		case
			when (total_transaksi2022 > total_transaksi2021) then 'Increase'
            when (total_transaksi2022 < total_transaksi2021) then 'Decrease'
		end as deskripsi
 from 
	transaksi2021
 left join transaksi2022 on transaksi2022.category = transaksi2021.category
 order by 
	grow desc;
    
-- 4. Tampilkan top 5 metode pembayaran yang paling populer digunakan selama 2022 (berdasarkan total unique order). Gunakan is_valid = 1 untuk memfilter data transaksi.
select
    payment_method,
    count(distinct od.id) as jumlah_ID
from 
	order_detail as od
left join payment_detail as pd on od.payment_id = pd.id
where 
	extract(year from od.order_date)= 2022
    and is_valid = 1
group by 
	payment_method
order by 
	jumlah_ID desc
limit 5;

-- 5. Urutkan dari ke-5 produk ini berdasarkan nilai transaksinya.
-- a. Samsung
-- b. Apple
-- c. Sony
-- d. Huawei
-- e. Lenovo
-- Gunakan is_valid = 1 untuk memfilter data transaksi.

with gadget_order as (
    select
		o.id, 
		s.sku_name,
			case
				when lower(s.sku_name) like '%samsung%' then 'Samsung'
				when lower(s.sku_name) like '%sony%' then 'Sony'
				when lower(s.sku_name) like '%huawei%' then 'Huawei'
				when lower(s.sku_name) like '%lenovo%' then 'Lenovo'
				when lower(s.sku_name) like '%apple%' or lower(s.sku_name) like '%iphone%' then 'Apple'
			end as nama_produk,
        sum(o.after_discount) as total_transaction
    from
		order_detail as o
    left join sku_detail as s on (o.sku_id = s.id)
    where
        extract(year from order_date) = 2022
        and s.category = 'Mobiles & Tablets' 
        and o.is_valid = 1
	group by 1, 2
)
select
	nama_produk,
	round(sum(total_Transaction)) as total_transaction
from
	gadget_order
where 
	nama_produk is not null
group by 
	nama_produk
order by 
	total_transaction desc;