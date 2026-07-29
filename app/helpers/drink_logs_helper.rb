module DrinkLogsHelper
  DEFAULT_BEGINNER_TASTE_TAG_ICON_FILE_NAME = "placeholder.webp"

  BEGINNER_TASTE_TAG_ICON_FILE_NAMES = {
    1 => "flower.webp",
    2 => "berry.webp",
    3 => "grape.webp",
    4 => "citrus.webp",
    5 => "apple.webp",
    6 => "stone.webp",
    7 => "tropical.webp",
    8 => "honey.webp",
    9 => "caramel.webp",
    10 => "nuts.webp",
    11 => "chocolate.webp",
    12 => "toast.webp"
  }.freeze

  def beginner_taste_tag_icon_file_name(tag)
    BEGINNER_TASTE_TAG_ICON_FILE_NAMES.fetch(tag.beginner_display_order, DEFAULT_BEGINNER_TASTE_TAG_ICON_FILE_NAME)
  end
end
