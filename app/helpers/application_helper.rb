module ApplicationHelper
  def app_paginate(records, params: {})
    return unless records.respond_to?(:total_pages)
    return if records.total_count.zero?

    return paginate(records, params:) if records.total_pages > 1

    render "shared/single_page_pagination", pagination_params: params
  end
end
