module MikuTwitter::APIShortcuts
  def blocked_ids
    cursor_pager(self/'blocks/ids', :json, :ids, {})
  end
end

Plugin.create(:blocked_user_mute) do
  block_list = []
  Service.primary.twitter.blocked_ids.next {|x|
    block_list = x
  }

  filter_show_filter do |msgs|
    msgs = msgs.reject do |msg|
      if msg.retweet? then
        block_list.include?(msg.retweet_source[:user].id)
      else
        block_list.include?(msg.user.id)
      end
    end
    [msgs]
  end
end
