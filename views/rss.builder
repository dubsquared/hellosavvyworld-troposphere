xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "New Images"
    xml.link request.url.chomp "rss.xml"
    @images.each do |image|
      xml.item do
        xml.title h image.md5
        xml.link "#{request.url.chomp "rss.xml"}/#{image.md5}"
        xml.guid "#{request.url.chomp "rss.xml"}/#{image.md5}"
        xml.pubDate Time.parse(image.created_at.to_s).rfc822
        xml.description h image.author
      end
    end
  end
end

