# Simple helper to check if the user is a moderator or not.
module SessionHelper
   def is_moderator?
       current_user.moderator?
   end

   def is_user_moderator
      unless is_moderator?
         redirect_to root_url
      end
   end
end