module HTML
  class Pipeline
    class EmbedFilter < HTML::Pipeline::Filter
      def call
        result[:embeddable_links] = doc.css('a.autolink').map { |a| a['href'] }
        doc
      end
    end
  end
end
