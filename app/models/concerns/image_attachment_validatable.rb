module ImageAttachmentValidatable
  extend ActiveSupport::Concern

  VALID_IMAGE_CONTENT_TYPES = [ "image/jpeg", "image/png", "image/webp" ].freeze
  MAX_IMAGE_SIZE_MB = 5
  MAX_IMAGE_SIZE = MAX_IMAGE_SIZE_MB.megabytes
  MAX_IMAGE_SIZE_TEXT = "#{MAX_IMAGE_SIZE_MB}MB"

  class_methods do
    def validates_image_attachment(attachment_name)
      validate do
        attachment = public_send(attachment_name)

        if attachment.attached?
          unless attachment.blob.content_type.in?(VALID_IMAGE_CONTENT_TYPES)
            errors.add(attachment_name, :invalid_image_type)
          end

          if attachment.blob.byte_size > MAX_IMAGE_SIZE
            errors.add(attachment_name, :image_too_large, max_size: MAX_IMAGE_SIZE_TEXT)
          end
        end
      end
    end
  end
end
