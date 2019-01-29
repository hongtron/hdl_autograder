module Comments
  def add_comment(comment)
    self.comments ||= ""
    self.comments = if self.comments.empty?
                 comment
               else
                 [self.comments, comment].join("; ")
               end
  end
end
