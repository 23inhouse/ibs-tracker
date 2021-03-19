require 'fileutils'

data_folder = "data"

TRACKING_MEAL_ITEMS_TSV_FILENAME = "#{data_folder}/tracking_meal_items.tsv"
CUSTOM_FOOD_ITEMS_TSV_FILENAME = "#{data_folder}/custom_food_items.tsv"
TRACKING_POINTS_TSV_FILENAME = "#{data_folder}/tracking_data_points.tsv"

BRISTOL_SCALES = {
  'null' => nil,
  '0' => 0,
  '14' => 1,
  '28' => 2,
  '42' => 3,
  '57' => 4,
  '71' => 5,
  '85' => 6,
  '100' => 7,
}

MODE_SCALES = {
  '' => nil,
  '0' => 0,
  '25' => 1,
  '50' => 2,
  '75' => 3,
  '100' => 4,
}

MEDICATION_NAMES = [
  "oregano",
  "glutamine",
  "garlic capsule",
  "allicin",
  "iberogast",
  "perenterol",
  "probiotic",
  "tablet",
  "vitamin",
  "ibuprofen",
  "enema",
  "colonic",
]

TAG_TRANSLATIONS = {
  "Erdnussbutter" => "peanut butter",
  "Kartoffelchips" => "Potato Chips",
  "Apfel" => "Apple",
  "Haferflocken" => "oatmeal",
  "Honig" => "honey",
  "Joghurt (Natur)" => "Natural yoghurt",
  "Mandeln" => "Almonds",
  "Zimt" => "cinnamon",
  "Kaffee" => "coffee",
  "Milch (Kuhmilch)" => "Milk (cow's milk)",
  "Schokolade (Milch)" => "Chocolate (milk)",
  "Hühnchen" => "chicken",
  "Kartoffeln" => "Potatoes",
  "Möhre" => "carrot",
  "Reis" => "rice",
  "Ei" => "egg",
  "Croissant" => "croissant",
  "Hart- und Schnittkäse" => "Hard and semi-hard cheese",
  "Brokkoli" => "broccoli",
  "Oliven" => "Olives",
  "Pasta  (aus Weizen)" => "Pasta (made from wheat)",
  "Pilze" => "Mushrooms",
  "Tomate" => "tomato",
  "Mangold" => "Swiss chard",
  "Thunfisch" => "tuna",
  "Tomatensoße" => "tomato sauce",
  "Spinat" => "spinach",
  "Banane" => "banana",
  "Wein, trocken" => "Wine, dry",
  "Fenchelknolle" => "Fennel bulb",
  "Ingwer" => "ginger",
  "Koriander" => "coriander",
  "Lachs" => "salmon",
  "Apfelessig" => "Apple Cider Vinegar",
  "Avocado" => "avocado",
  "Balsamico" => "Balsamic vinegar",
  "Quark" => "Quark",
  "Knoblauch" => "garlic",
  "Pastinake" => "parsnip",
  "Oregano" => "oregano",
  "Schokolade  (dunkel, 60-69% Kakao-Anteil)" => "Chocolate (dark, 60-69% cocoa content)",
  "Salatblätter" => "Lettuce leaves",
  "Bohne (grün)" => "Bean (green)",
  "Cracker" => "cracker",
  "Butter" => "butter",
  "Aubergine" => "aubergine",
  "Bier" => "beer",
  "Kapern" => "Capers",
  "Erdbeermarmelade" => "Strawberry jam",
  "Senf" => "mustard",
  "Hummus" => "Hummus",
  "Brötchen (Weizen, Dinkel, Roggen)" => "Rolls (wheat, spelled, rye)",
  "Erdnüsse" => "peanuts",
  "Kürbiskerne" => "Pumpkin seeds",
  "Pizza (mit Tomaten und Käse)" => "Pizza (with tomatoes and cheese)",
  "Schinken" => "ham",
  "Speck" => "bacon",
  "Suppe" => "Soup",
  "Wurst" => "sausage",
  "Trauben" => "Grapes",
  "Hafermilch" => "Oat milk",
  "Reismilch" => "Rice milk",
  "Mandelmilch" => "Almond milk",
  "Feigen" => "Figs",
  "Wasabi" => "Wasabi",
  "Dinkel oder Weizen Sauerteigbrot mit einer Gehzeit von mind. 4.5 Stunden" => "Spelled or wheat sourdough bread with a walking time of at least 4.5 hours",
  "Knoblauch-Öl" => "Garlic oil",
  "Erdbeeren" => "Strawberries",
  "Wasser (ohne Kohlensäure)" => "Non-carbonated water",
  "Eisbergsalat" => "Iceberg lettuce",
  "Hamburger (Patty, Brötchen)" => "Hamburger (Patty, Bun)",
  "Ketchup" => "Ketchup",
  "Mayonnaise" => "mayonnaise",
  "Pommes Frites" => "French fries",
  "Saure Gurken" => "Pickled cucumbers",
  "Weichkäse" => "Soft cheese",
  "Linsen (rot)" => "Lentils (red)",
  "Himbeeren" => "Raspberries",
  "Birne" => "pear",
  "Feta" => "Feta",
  "Körnerbrötchen (Weizen, Dinkel, Roggen)" => "Grain rolls (wheat, spelled, rye)",
  "Rindfleisch" => "Beef",
  "Kiwi" => "Kiwi fruit",
  "Rosenkohl" => "Brussels sprouts",
  "Sauerkraut" => "Sauerkraut",
  "Zucchini" => "Zucchini",
  "Fisch" => "Fish",
  "Gurke" => "Gherkin",
  "Zitrone" => "Lemon",
  "Dinkelkeks" => "Spelt cracker",
  "Pak Choi" => "Mangold",
  "Tee (sonstige)" => "Tea (other)",
  "Sojasprossen" => "Bean sprouts",
  "Cashewkerne" => "Cashew nuts",
  "Haselnüsse" => "Hazelnuts",
  "Macadamianüsse" => "Macadamia nuts",
  "Walnüsse" => "Walnuts",
  "Gewürzmischungen mit Knoblauch und Zwiebeln" => "Spice mix w/ onions & garlic",
  "Paprika" => "Paprika",
  "Muskat" => "Nutmeg",
}

FOOD_TAGS_TO_REMOVE = [
  "Foul smelling",
  "Sweet smelling",

  "Partial evacuation",
  "Full evacuation",

  "No too wet", # (Not too wet)
  "A bit wet",
  "Very wet",

  "Not too dry",
  "A bit dry",
  "Very dry",

  "No pressure",
  "Hardly any pressure",
  "A bit of pressure",
  "Medium pressure",
  "Huge pressure",
  "Extreme pressure",

  "Black",
  "White",
  "Green",
  "Red",
  "Orange",
  "Yellow",

  "Urgent",
  "Mostly liquid",
  "Undigested spinach",
]

CARA_CARE_DATA_ERRORS = {
  "2020-09-15 09:30:00 +0000" => [:skin, :next],
  "2020-10-21 09:10:00 +0000" => [:gut, :next],
  "2020-10-23 18:05:00 +0000" => [:medication, :next],
  "2021-01-06 15:25:00 +0000" => [:note, :prev],
  "2021-01-09 18:35:00 +0000" => [:food, :next],
  "2021-01-24 08:10:00 +0000" => [:note, :next],
  "2021-01-24 19:20:00 +0000" => [:food, :prev],
  "2021-02-05 22:20:00 +0000" => [:food, :prev],
  "2021-03-08 21:05:00 +0000" => [:food, :prev],
}

def mode(tracking_id, tracking_type, tracking_text, tag_names)
  if tracking_type == "food"
    text = text(:food, tracking_id, '', tag_names)
    if MEDICATION_NAMES.any? { |med| text.downcase.include? med.downcase }
      mode, submode = medication?(text)
    elsif text.downcase.include? " again"
      food_again = text.downcase[0..-7]
      # puts "[AGAIN] Search for previous: #{food_again}"
      mode = :food
    else
      mode = :food
    end
  elsif tracking_type == "stool"
    mode = :bm
  elsif tracking_type == "bloating"
    mode = :gut
    submode = :bloating
  elsif tracking_type == "pain"
    mode = :gut
    submode = :pain
  elsif tracking_type == "headache"
    mode = :ache
    submode = :headache
  elsif tracking_type == "otherPain"
    mode = :ache
    submode = :bodyache
  elsif tracking_type == "mood"
    mode = :mood
    submode = :feel
  elsif tracking_type == "stress"
    mode = :mood
    submode = :stress
  elsif tracking_type == "skin"
    mode = :skin
  elsif tracking_type == "notes"
    if MEDICATION_NAMES.any? { |med| tracking_text.downcase.include? med.downcase }
      mode, submode = medication?(tracking_text)
    elsif tracking_text.downcase.include? "ulcer"
      mode = :skin
    elsif tracking_text.include? "kg"
      mode = :weight
    else
      mode = :note
    end
  end

  return mode, submode, food_again
end

def medication?(text)
  text = text.downcase
  if MEDICATION_NAMES.any? { |med| text.include? med.downcase }
    mode = :medication
    if ["oregano", "garlic capsule", "allicin"].any? { |med| text.include? med }
      submode = :antimicrobial
    elsif ["enema", "colonic"].any? { |med| text.include? med }
      submode = :other
    elsif ["perenterol", "probiotic"].any? { |med| text.include? med }
      submode = :probiotic
    elsif ["iberogast"].any? { |med| text.include? med }
      submode = :prokinetic
    elsif ["glutamine"].any? { |med| text.include? med }
      submode = :suppliment
    elsif ["vitamin"].any? { |med| text.include? med }
      submode = :vitamin
    elsif ["ibuprofen"].any? { |med| text.include? med }
      submode = :analgesic
    end
  end
  return mode, submode
end

def timestamp(timestamp)
  if !['0', '5'].include? timestamp[15]
    original_timestamp = timestamp.dup
    precision = 5
    minute = (timestamp[15].to_f / precision).round * precision
    timestamp[15] = minute.to_s[-1]
    if minute == 10
      timestamp[14] = (timestamp[14].to_i + 1).to_s
      if timestamp[14] == '6'
        timestamp[14] = '0'
        if timestamp[12] == '9'
          timestamp[12] = '0'
          timestamp[11] = (timestamp[11].to_i + 1).to_s
        else
          timestamp[12] = (timestamp[12].to_i + 1).to_s
        end

        # puts "Corrected timestamp: [#{original_timestamp}] -> [#{timestamp}]"
        if timestamp[11..12] == '25'
          puts "Error: Invalid timestamp [#{timestamp}]"
          exit
        end
      end
    end
  end
  timestamp = "#{timestamp[0..15]}:00 +0000"

  return timestamp
end

def text(mode, id, text, tag_names)
  if [:food, :medication].include? mode
    if tag_names[id].nil?
      if !text.include?("Enema") && !text.include?("Colonic")
        puts "Warning: No name for [#{id}] in associated_tags using [#{text}]"
      end
      return text
    else
      tag_names[id] ||= []
      tag_names[id][0]
    end
  elsif mode == :note || mode == :skin
    text
  end
end

def bristol_scale(value)
  BRISTOL_SCALES[value] || "null"
end

def scale(value, next_timestamp)
  scale = MODE_SCALES[value]

  # adjust pain levels because I was under reporting the pain
  scale = scale.to_i + 1 if scale != nil && scale < 5 && next_timestamp < "2020-12-21"# && scale.to_i > 0

  return scale || "null"
end

def weight(tracking_text)
  tracking_text.scan(/[\d\.]+/).first
end

def condition(tracking_text)
  tracking_text ||= ""
  condition = "null"
  condition = "2" if ["ulcer"].any? { |w| tracking_text.downcase.include? w }
  condition = "1" if ["tiny", "mini", "small", "flat", "shrank"].any? { |w| tracking_text.downcase.include? w }
  condition = "3" if ["bigger"].any? { |w| tracking_text.downcase.include? w }
  condition = "4" if ["sore", "swollen", "second", "big"].any? { |w| tracking_text.downcase.include? w }
  return condition
end

def tags(mode, id, tags, tag_names, text)
  if [:food, :medication].include? mode
    if tag_names[id].nil?
      text = text.downcase
      inline_tags = []
      inline_tags << "Enema" if text.include? "enema"
      inline_tags << "Colonic" if text.include? "colonic"
      inline_tags << "Saccharomyces boulardii" if text.include? "perenterol"
      if text.downcase.include?("bifidobacterium") ||
        text.downcase.include?("lactobacillus") ||
        text.downcase.include?("probiotic")
        inline_tags << "Bifidobacterium"
        inline_tags << "Lactobacillus"
      end
      inline_tags << "Allicin" if text.include? "garlic"
      inline_tags << "Oregano" if text.include? "oregano"
      inline_tags << "L-Glutamine" if text.include? "l-glutamine"
      # return text
    end

    tag_names[id] ||= []
    associated_tags = tag_names[id][1]
  else
    inline_tags = tags.split(/\s?\|\s?/) || []
  end

  associated_tags ||= []
  inline_tags ||= []

  (associated_tags << inline_tags)
    .flatten
    .reject(&:nil?)
    .map { |tag| tag.scan(/\"?([^"]*)\"?/i).first.last }
    .map(&:capitalize)
end

def process_line(line, prev_mode, prev_submode, prev_timestamp, prev_scale, tag_names, food_records)
  if line.nil?
    puts "Error: line is empty"
    return next_mode, next_submode, prev_timestamp, prev_scale, food_records
  end

  # assign values
  parts = line.split(/\t/)
  tracking_id, tracking_type, timestamp_tracking, timestamp_entry, timestamp_last_modified, tracking_value, tracking_text, tracking_tags, medication, medication_unit = parts

  # mode
  mode, submode, food_again = mode(tracking_id, tracking_type, tracking_text, tag_names)
  next_mode = mode
  next_submode = submode

  # guard against header rows
  if mode == nil
    return next_mode, next_submode, prev_timestamp, prev_scale, food_records
  end

  # guard against empty ache, gut, mood records
  if [:ache, :gut, :mood].include?(mode) && tracking_value.empty?
    # puts [timestamp_tracking[0...16], mode, submode].join(' | ')
    puts "Skipping: Empty scale record [#{mode}]"
    return next_mode, next_submode, prev_timestamp, prev_scale, food_records
  end

  next_timestamp = timestamp(timestamp_tracking)

  if !(next_timestamp >= prev_timestamp) && prev_timestamp != 'holder'
    puts "Error: records are not in ascending order. PREV [#{prev_timestamp}] NEXT [#{next_timestamp}]"
    exit
  end

  if CARA_CARE_DATA_ERRORS[next_timestamp] == [next_mode, :prev] && prev_timestamp != next_timestamp
    puts "Erroneous data: Skipping Prev [#{next_timestamp}] [#{next_mode}]"
    return next_mode, next_submode, next_timestamp, prev_scale, food_records
  end

  if CARA_CARE_DATA_ERRORS[next_timestamp] == [next_mode, :next] && prev_timestamp == next_timestamp
    puts "Erroneous data: Skipping Next [#{next_timestamp}] [#{next_mode}]"
    return next_mode, next_submode, next_timestamp, prev_scale, food_records
  end

  # brististol_scale
  next_bristol_scale = bristol_scale(tracking_value)

  # scale
  next_scale = scale(tracking_value, next_timestamp)

  # text
  next_text = text(next_mode, tracking_id, tracking_text, tag_names)

  # tags
  next_tags = tags(next_mode, tracking_id, tracking_tags, tag_names, tracking_text)

  # weight
  next_weight = weight(tracking_text) if mode == :weight

  # weight
  next_condition = condition(tracking_text) if mode == :skin

  if food_again
    # puts "[AGAIN]   Searching... (#{food_records.count}) records for [#{food_again}]"
    food_records.reverse.each do |food_name, food_tags|
      if food_name.downcase.include? food_again
        # puts "[AGAIN]   Found: [#{food_name}]"
        next_text = "#{food_name}"
        next_tags = food_tags
        food_records = []
        break
      end
    end
  end

  if next_mode == :food && next_tags.empty?
    # puts "Skipping: [#{next_mode}] #{next_timestamp} #{next_text} [No tags]"
    return next_mode, next_submode, prev_timestamp, prev_scale, food_records
  end

  if ![:gut, :mood, :ache].include?(next_mode) && next_timestamp == prev_timestamp && !CARA_CARE_DATA_ERRORS[next_timestamp]
    puts
    puts "DUPLICATE !!!: [#{next_mode}] #{next_timestamp} !!!"
    puts
  end

  lines = []
  case mode
  when :bm
    smell = "null"
    smell = '"sweet"' if next_tags.include? "Sweet smelling"
    smell = '"foul"' if next_tags.include? "Foul smelling"
    color = "null"
    color = '"yellow"' if next_tags.include? "Yellow"
    pressure = "null"
    pressure = "1" if next_tags.include? "Hardly any pressure"
    pressure = "1" if next_tags.include? "A bit of pressure"
    pressure = "2" if next_tags.include? "Medium pressure"
    pressure = "3" if next_tags.include?("Huge pressure") || next_tags.include?("Urgent")
    pressure = "4" if next_tags.include? "Extreme pressure"
    evacuation = "null"
    evacuation = '"partial"' if next_tags.include? "Partial evacuation"
    evacuation = '"full"' if next_tags.include? "Full evacuation"
    wetness = "null"
    wetness = "1" if next_tags.include? "No too wet"
    wetness = "2" if next_tags.include? "A bit wet"
    wetness = "3" if next_tags.include? "Very wet"
    wetness = "3" if next_tags.include? "Mostly liquid"
    dryness = "null"
    dryness = "1" if next_tags.include? "Not too dry"
    dryness = "2" if next_tags.include? "A bit dry"
    dryness = "3" if next_tags.include? "Very dry"

    next_tags << "Undigested leafy" if next_tags.include? "Undigested spinach"
    if i = next_tags.index("Mr whippy")
      next_tags[i] = "Mr Whippy"
    end
    next_tags = next_tags - FOOD_TAGS_TO_REMOVE
    lines << <<-END
      |       "type": "#{next_mode}",
      |       "timestamp": "#{timestamp(timestamp_tracking)}",
      |       "bristol-scale": #{next_bristol_scale},
      |       "smell": #{smell},
      |       "color": #{color},
      |       "pressure": #{pressure},
      |       "evacuation": #{evacuation},
      |       "wetness": #{wetness},
      |       "dryness": #{dryness},
      |       "tags": #{next_tags}
    END
  when :gut, :ache, :mood
    if next_submode != prev_submode && next_mode == prev_mode && next_timestamp == prev_timestamp
      lines << <<-END
        |       "type": "#{next_mode}",
        |       "timestamp": "#{next_timestamp}",
        |       "#{prev_submode}": #{prev_scale},
        |       "#{next_submode}": #{next_scale},
        |       "tags": #{next_tags}
      END
      merged_properties = true
    else
      lines << <<-END
        |       "type": "#{next_mode}",
        |       "timestamp": "#{next_timestamp}",
        |       "#{next_submode}": #{next_scale},
        |       "tags": #{next_tags}
      END
    end
  when :medication
    medication_type = [next_submode]

    drops = next_text.scan /( (\d+ drops))/
    if drops.first && drops.first.first
      next_text.slice! drops.first.first
      next_tags << drops.last.last
    end

    next_text = "Ibuprofen" if next_text == "Ibuprofen 400"
    next_text = "Allicin capsule" if next_text == "Allicin 1 capsule"
    if next_text == "Oregano & garlic tablets - garlic only"
      next_text = "Allicin capsule"
      next_tags = ["Allicin"]
    end
    next_text = "Oregano & Allicin capsules" if next_text == "Oregano & garlic tablets"
    next_text = "L-Glutamine & Oregano & Allicin capsules" if next_text == "L-Glutamine & Oregano & garlic tablets"
    next_text = "L-Glutamine" if next_text == "L-Glutamine 5g"
    if next_text == "Perenterol tablet"
      next_text = "Perenterol capsule"
      next_tags << "Saccharomyces boulardii"
    end

    if ["Vitamin tablet", "Vitamins"].include? next_text
      next_text = "Vitamin tablet"
      next_tags = ["Multi-vitamin"]
    end

    cleaned_tags = []
    next_tags.each do |next_tag|
      next_tag.slice! " capsule" if next_tag.include? " capsule"
      next_tag = "Allicin" if next_tag == "Garlic"
      next_tag = "L-Glutamine" if next_tag == "L-glutamine"
      next_tag = "Vitamin B9" if next_tag == "Vitamin b9"
      next if next_tag == "Probiotic"
      cleaned_tags << next_tag
    end
    next_tags = cleaned_tags

    next_tags << 'L-Glutamine' if next_text == 'L-Glutamine' && !next_tags.include?('L-Glutamine')

    if next_text.include? "Enema"
      next_text = "Enema"
      medication_type << :other
      enema_with = []
      enema_with << "L-Glutamine" if next_tags.include? "L-Glutamine"
      enema_with << "Perenterol" if next_tags.include? "Saccharomyces boulardii"
      enema_with << "MyBIOTIK" if next_tags.include? "Lactobacillus"
      next_text = "#{next_text} w/ #{enema_with.join(' & ')}" if !enema_with.empty?
    end

    medication_type << :suppliment if next_tags.include? "L-Glutamine"
    medication_type << :probiotic if next_tags.include? "Saccharomyces boulardii"
    medication_type << :probiotic if next_tags.include? "Lactobacillus"
    medication_type << :other if next_tags.include? "Colonic"

    lines << <<-END.gsub(/^%m\|/, '\n')
      |       "type": "#{next_mode}",
      |       "timestamp": "#{next_timestamp}",
      |       "medication-type": #{medication_type.uniq.map(&:to_s)},
      |       "text": "#{next_text}",
      |       "tags": #{next_tags.uniq}
    END
  when :weight
    lines << <<-END
      |       "type": "#{next_mode}",
      |       "timestamp": "#{next_timestamp}",
      |       "weight": #{next_weight},
      |       "tags": #{next_tags}
    END
  when :food
    size = "null"
    size = "4" if next_text.downcase.include? "large"
    size = "5" if next_text.downcase.include? "huge"
    risk = "null"
    risk = "2" if next_text.downcase.include? "questionable"
    risk = "4" if next_text.downcase.include? "risky"

    medicinal = false
    if ["Turmeric tea", "Apple cider vinegar"].any? { |meds| next_text.include? meds }
      medicinal = true
    end

    if ["Milk"].include? next_text
      medicinal = true
    end

    cleaned_tags = []
    next_tags.each do |next_tag|
      next_tag = "Gherkin" if next_tag == "Pickled cucumbers"
      cleaned_tags << next_tag
    end
    next_tags = cleaned_tags

    lines << <<-END
      |       "type": "#{next_mode}",
      |       "timestamp": "#{next_timestamp}",
      |       "text": "#{next_text}",
      |       "size": #{size},
      |       "risk": #{risk},
      |       "medicinal": #{medicinal},
      |       "tags": #{next_tags.uniq}
    END
    food_records << [next_text, next_tags]
  when :skin
    next_tags = ["Ulcer"] if next_text.downcase.include? "ulcer"
    lines << <<-END
      |       "type": "#{next_mode}",
      |       "timestamp": "#{next_timestamp}",
      |       "text": "#{next_text}",
      |       "condition": #{next_condition},
      |       "tags": #{next_tags}
    END
  else # :note
    lines << <<-END
      |       "type": "#{next_mode}",
      |       "timestamp": "#{next_timestamp}",
      |       "text": "#{next_text}",
      |       "tags": #{next_tags}
    END
  end

  return next_mode, next_submode, next_timestamp, next_scale, food_records, lines, merged_properties
end

#
#
#  Excute the script here
#
#

tag_names = {}

# load custom meal tags
File.readlines(CUSTOM_FOOD_ITEMS_TSV_FILENAME).each do |line|
  parts = line.split(/\t/)
  id = parts[0]
  tags = parts[1]
  tags.strip!
  tag_names[id] = ["noname", tags]
end

# puts tag_names

# load meal tags
File.readlines(TRACKING_MEAL_ITEMS_TSV_FILENAME).each do |line|
  parts = line.split(/\t/)

  next if parts[0] == 'Realmidstring'

  id = parts[1]
  name = parts[7]
  name = name.match(/\"?([^"]*)\"?/i).to_a[1] # remove quotes

  custom_tags = parts[4]
  untranslated_tags = parts[3]

  tags = []
  if !custom_tags.empty?
    custom_food_item_ids = custom_tags
    custom_food_item_ids = custom_food_item_ids.split(" ★ ")

    custom_food_item_ids.map do |item_id|
      tag_names[item_id] ||= []
      tags << tag_names[item_id][1]
    end
  end

  if !untranslated_tags.empty?
    # tags = untranslated_tags
    untranslated_tags = untranslated_tags.split(" ★ ")
    untranslated_tags.collect! { |tag| tag.match(/\"?([^"]*)\"?/i).to_a[1] }
    # translated_tags = []
    for tag in untranslated_tags
      # # store untranslated tags for google translate
      # next if all_tags[tag]
      # all_tags[tag] = all_tags.values.last + 1

      if !TAG_TRANSLATIONS[tag]
        puts
        puts "Error: MISSING TRANSLATION !!! [#{tag}] !!!"
        puts
      end
      safe_tag = TAG_TRANSLATIONS[tag] || tag
      # translated_tags << safe_tag
      tags << safe_tag
    end
  end

  tag_names[id] = [name, tags.compact] if tag_names[id].nil? || tag_names[id].empty?
end
# puts '----------'
# puts tag_names

OUTPUT_FILENAME = "records.json"
# system("touch #{OUTPUT_FILENAME}")

open(OUTPUT_FILENAME, 'w') do |output_file|
  # all_tags = { "tag": 0 }

  lines = []
  next_timestamp = "holder"
  prev_timestamp = "firstrun"
  next_mode = "holder"
  prev_mode = "firstrun"
  next_submode = "holder"
  prev_submode = "firstrun"
  next_scale = "holder"
  prev_scale = "firstrun"

  food_records = []

  prev_line = nil

  prev_lines = nil
  next_lines = nil

  output_file << <<-END.gsub(/^\s+\|/, '')
    |{
    |  "ibs-records": [
    |    {
  END

  File.readlines(TRACKING_POINTS_TSV_FILENAME).each do |line|
    # puts '-----'
    # puts line

    next_mode,
    next_submode,
    next_timestamp,
    next_scale,
    food_records,
    next_lines,
    merged_properties = process_line(line, next_mode, next_submode, next_timestamp, prev_scale, tag_names, food_records)

    if [next_mode, next_timestamp].include?(nil) && !line.include?("Realmidstring")
      puts "Error: Missing next_mode or next_timestamp"
    end

    if !prev_lines.nil? && !merged_properties
      if !prev_line.nil?
        output_file << <<-END.gsub(/^\s+\|/, '').gsub(/^%m\|/, '\n')
          |    },
          |    {
        END
      end
      prev_line = line

      output_file << prev_lines.join.gsub(/^\s+\|/, '').gsub(/^%m\|/, '\n')
    end

    prev_scale = next_scale
    prev_lines = next_lines
  end

  output_file << <<-END.gsub(/^\s+\|/, '').gsub(/^%m\|/, '\n')
    |    }
    |  ]
    |}
  END
end
