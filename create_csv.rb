require 'date'
require 'faker'
require 'json'
require 'optparse'

opts = ARGV.getopts('hb', 'show-header', 'show-body')
show_header = opts['h'] || opts['show-header'] || (!opts['b'] && !opts['show-body'])
show_body = opts['b'] || opts['show-body'] || (!opts['h'] && !opts['show-header'])

# 引数例: jsons/000/*, jsons/00*/*, jsons/000/* jsons/001/* など
args = ARGV

system('rm items_v1.csv') if File.exist?('items_v1.csv')

MAX_SUB_IMAGE_NUMBER=29

# SALES_AREA = %w(hk tw kr)
SALES_AREA_COLORS = %w(sales-area-whitelist sales-area-blacklist)

HEADER = %w(code shop-code name name@en name@chs name@cht variations price description description@en description@chs description@cht meta-keywords meta-keywords@en meta-keywords@chs meta-keywords@cht meta-description meta-description@en meta-description@chs meta-description@cht visible sale-price sale-period-start sale-period-end buyable-quantities-at-once product-code jan item-origin-url category-codes copyright copyright@en copyright@chs copyright@cht buyable-period-start buyable-period-end used sales-area-whitelist sales-area-blacklist main-image-url).push( *(1..MAX_SUB_IMAGE_NUMBER).map{|i| "sub-image-url-#{i}"} )

# サンプル的なvariations
VARIATIONS = %w(色:赤#サイズ:S=RS001&色:赤#サイズ:M=RM001&色:赤#サイズ:L=RL001&色:黄#サイズ:S=YS001&色:黄#サイズ:M=YM001&色:黄#サイズ:L=YL001&色:青#サイズ:S=BS001&色:青#サイズ:M=BM001&色:青#サイズ:L=BL001 色:赤=red 色:赤=red&色:青=blue 色:赤#サイズ:S=red-s 色:赤#サイズ:S=red-s&色:赤#サイズ:M=red-m&色:青#サイズ:S=blue-s&色:青#サイズ:M=blue-m)

puts HEADER.join(',') if show_header

Array.new(args).each.with_index do |json_file,file_no|
  File.open(json_file) do |f|
    begin
      # 前処理
      json = JSON.parse(f.read)
      item = json['item']

      sale_start_time    = Faker::Time.between(Time.local(2015, 01, 01), Time.local(2015, 12, 31))
      sale_end_time      = sale_start_time + (60 * 60)

      buyable_start_time = DateTime.parse(item['orderable_start'])
      buyable_end_time   = DateTime.parse(item['orderable_end'])

      # それぞれのカラムに対応するデータを定義
        code                      = item['item_code']
        shop_code                 = json['partners'][0]['partner_id'] # 一番ショップコードに近く、リアルなデータ
        name                      = item['title']
        name_en                   = "name_en"
        name_chs                  = "我们想要吃"
        name_cht                  = "我们想要吃"
        # comvinationやoptionsがnilの場合は見送る
        begin
          variations = item['variations'].map { |variation|
            variation['combination'].map { |opt_code, opt_value_code|
              option_name = item['options'].find { |o| o['option_code'] == opt_code }['title']
              option_value = item['options']
                .find {|o| o['option_code'] == opt_code }['values']
                .find {|v| v['value'] == opt_value_code }['name']
              "#{option_name}:#{option_value}"
            }.join('#') + "=#{variation['sku']}"
          }.join('&')
        rescue
          variations = ""
        end

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
        product_code               = item['product_code']
        jan                        = item['jan']
        item_origin_url            = item['item_origin_url']
        category_codes = item['categories'].compact
          .map { |cat_route| cat_route&.max { |c1,c2| c1['depth'] <=> c2['depth'] } }  # depth が一番大きいやつ
          .reject { |cat| cat['category_id'].include? 'p-bandai' }  # バンダイカテゴリを除外
          .map { |cat| cat['category_id'] }  # category から id だけ抽出
          .join(' ')
        main_image_url             = item['images'][0]&.dig('url')
        sub_image_urls             = item['images'][1..MAX_SUB_IMAGE_NUMBER].map{|img| img['url'] }
        copyright                  = item['copyright'] || 'copyright'
        copyright_en               = 'copyright_en'
        copyright_chs              = 'copytight_chs'
        copyright_cht              = 'copyright_cht'
        buyable_period_start       = [buyable_start_time.strftime('%Y%m%d'), buyable_start_time.strftime('%Y%m%d%H'), buyable_start_time.strftime('%Y%m%d%H%M')].sample
        buyable_period_end         = [buyable_end_time.strftime('%Y%m%d'), buyable_end_time.strftime('%Y%m%d%H'), buyable_end_time.strftime('%Y%m%d%H%M')].sample
        used                       = item['condition']
        if item['country_options']
          sales_area_whitelist         = item['country_options']['buyable']['allow']&.join(' ') if file_no % 2 == 0
          sales_area_blacklist         = item['country_options']['buyable']['deny']&.join(' ') if file_no % 2 == 1
        end
      values = %W(#{code} #{shop_code} #{name} #{name_en} #{name_chs} #{name_cht} #{variations} #{price} #{description} #{description_en} #{description_chs} #{description_cht} #{meta_keywords} #{meta_keywords_en} #{meta_keywords_chs} #{meta_keywords_cht} #{meta_description} #{meta_description_en} #{meta_description_chs} #{meta_description_cht} #{visible} #{sale_price} #{sale_period_start} #{sale_period_end} #{buyable_quantities_at_once} #{product_code} #{jan} #{item_origin_url} #{category_codes} #{copyright} #{copyright_en} #{copyright_chs} #{copyright_cht} #{buyable_period_start} #{buyable_period_end} #{used} #{sales_area_whitelist} #{sales_area_blacklist} #{main_image_url}).push( *(1..MAX_SUB_IMAGE_NUMBER).map{|i| sub_image_urls[i]} )
      puts values.map{|v| "\"#{ v&.gsub('"', '""') }\"" }.join(',')
    rescue
      STDERR.puts "error occured in processing #{json_file}"
      raise
    end
  end
end if show_body
