class ButtonResponse < OpenStruct
  def handle!
    return unless service.locked?
    return if service.lock_owner != user_id

    case action
    when "extend"
      service.extend_lock(seconds: 15 * 60)
      update_message("Perfect! We've added 15 minutes to your lock timer!")
    when "unlock"
      service.expire_lock!
      update_message("Perfect! We've unblocked #{service.name}!")
    end
  end

  def ts
    message_ts
  end

  def channel_id
    channel["id"]
  end

  private

  def update_message(text)
    SlackNotifier.new.remove_attachments(self, text: text)
  end

  def user_id
    user["id"]
  end

  def service
    @service ||= begin
      name = callback_id.sub(/^action_/i, "")
      Service.new(name)
    end
  end

  def action
    actions.first["value"]
  end
end