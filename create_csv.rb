require 'date'
require 'faker'
require 'json'

# 引数例: jsons/000/*, jsons/00*/*, jsons/000/* jsons/001/* など
args = ARGV

system('rm items_v1.csv') if File.exist?('items_v1.csv')

# SALES_AREA = %w(hk tw kr)
SALES_AREA_COLORS = %w(sales-area-white sales-area-black)

HEADER = %w(code shop-code name name@en name@chs name@cht variations price description description@en description@chs description@cht meta-keywords meta-keywords@en meta-keywords@chs meta-keywords@cht meta-description meta-description@en meta-description@chs meta-description@cht visible sale-price sale-period-start sale-period-end buyable-quantities-at-once product-code jan item-origin-url category-codes main-image-url sub-image-url-1 copyright copyright@en copyright@chs copyright@cht buyable-period-start buyable-period-end used).push(SALES_AREA_COLORS.sample)

# サンプル的なvariations
VARIATIONS = %w(色:赤#サイズ:S=RS001&色:赤#サイズ:M=RM001&色:赤#サイズ:L=RL001&色:黄#サイズ:S=YS001&色:黄#サイズ:M=YM001&色:黄#サイズ:L=YL001&色:青#サイズ:S=BS001&色:青#サイズ:M=BM001&色:青#サイズ:L=BL001 色:赤=red 色:赤=red&色:青=blue 色:赤#サイズ:S=red-s 色:赤#サイズ:S=red-s&色:赤#サイズ:M=red-m&色:青#サイズ:S=blue-s&色:青#サイズ:M=blue-m)

puts HEADER.join(',')

Array.new(args).each do |json_file|
  File.open(json_file) do |f|
    # 前処理
    json = JSON.parse(f.read)
    item = json['item']

    sale_start_time    = Faker::Time.between(Time.local(2015, 01, 01), Time.local(2015, 12, 31))
    sale_end_time      = sale_start_time + (60 * 60)

    buyable_start_time = DateTime.parse(item['orderable_start'])
    buyable_end_time   = DateTime.parse(item['orderable_end'])

    main_image = item['images'].select { |img| img['url'].include?('main') }

    # それぞれのカラムに対応するデータを定義
    code                      = item['item_code']
    shop_code                 = json['partners'][0]['partner_id'] # 一番ショップコードに近く、リアルなデータ
    name                      = item['title']
    name_en                   = "name_en"
    name_chs                  = "我们想要吃"
    name_cht                  = "我们想要吃"
    colors                    = item['options'].flat_map { |op| op['values'].map { |value| "色:#{value['name']}" } if op['option_code'] == 'color' }.compact!
    variations                = item['options'].flat_map { |op| op['values'].map { |value| "#{colors.sample}#サイズ:#{value['name']}=id-#{value['name'].downcase}" }.join('&') if op['option_code'] == 'size' }.compact!&.pop
    price                     = item['price']
    description               = item['description']
    description_en            = "description_en"
    description_chs           = "我们想要吃"
    description_cht           = "我们想要吃"
    meta_keywords             = item['meta_keywordswords']
    meta_keywords_en          = "meta_keywords_en"
    meta_keywords_chs         = "我们想要吃"
    meta_keywords_cht         = "我们想要吃"
    meta_description          = item['meta_description']
    meta_description_en       = "meta_desc_en"
    meta_description_chs      = "我们想要吃"
    meta_description_cht      = "我们想要吃"
    visible                   = rand(2)
    sale_price                = [nil, price - 50, price - 100].sample
    if sale_price.nil?
      sale_period_start, sale_period_end = nil
    else
      sale_period_start  = [sale_start_time.strftime('%Y%m%d'), sale_start_time.strftime('%Y%m%d%H'), sale_start_time.strftime('%Y%m%d%H%M'), nil].sample
      sale_period_end    = [sale_end_time.strftime('%Y%m%d'), sale_end_time.strftime('%Y%m%d%H'), sale_end_time.strftime('%Y%m%d%H%M'), nil].sample
      sale_price         = nil if sale_period_start.nil? && sale_period_end.nil?
    end
    buyable_quantities_at_once = item['sale_limit']
    product_code               = item['item_code']
    jan                        = item['jan']
    item_origin_url            = item['item_origin_url']
    cates = []
    item['categories'].each_with_index do |categories, i|
      categories.each { |category| cates << category['category_id'] if category['depth'] == i + 1 && !category['category_id'].include?('p-bandai')} if categories
    end if item['categories']
    category_codes             = cates.join(' ')
    main_image_url             = main_image[0]['url']
    sub_image_url_1            = "http://buyee.jp/images/common/top/flow_purchase.png"
    copyright                  = item['copyright'] || 'copyright'
    copyright_en               = 'copyright_en'
    copyright_chs              = 'copytight_chs'
    copyright_cht              = 'copyright_cht'
    buyable_period_start       = [buyable_start_time.strftime('%Y%m%d'), buyable_start_time.strftime('%Y%m%d%H'), buyable_start_time.strftime('%Y%m%d%H%M')].sample
    buyable_period_end         = [buyable_end_time.strftime('%Y%m%d'), buyable_end_time.strftime('%Y%m%d%H'), buyable_end_time.strftime('%Y%m%d%H%M')].sample
    used                       = item['condition']
    if item['country_options']
      sales_area_white         = item['country_options']['buyable']['allow'].join(' ') if HEADER.include? 'sales-area-white'
      sales_area_black         = item['country_options']['buyable']['deny'].join(' ') if HEADER.include? 'sales-area-black'
    end

    values = %W(#{code} #{shop_code} #{name} #{name_en} #{name_chs} #{name_cht} #{variations} #{price} #{description} #{description_en} #{description_chs} #{description_cht} #{meta_keywords} #{meta_keywords_en} #{meta_keywords_chs} #{meta_keywords_cht} #{meta_description} #{meta_description_en} #{meta_description_chs} #{meta_description_cht} #{visible} #{sale_price} #{sale_period_start} #{sale_period_end} #{buyable_quantities_at_once} #{product_code} #{jan} #{item_origin_url} #{category_codes} #{main_image_url} #{sub_image_url_1} #{copyright} #{copyright_en} #{copyright_chs} #{copyright_cht} #{buyable_period_start} #{buyable_period_end} #{used})
    values.push(sales_area_white) if HEADER.include? 'sales-area-white'
    values.push(sales_area_black) if HEADER.include? 'sales-area-black'
    puts values.join(',')
  end
end
