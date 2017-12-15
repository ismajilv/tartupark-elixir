# defimpl Canada.Can, for: Tartupark.User do
#   def can?(user, action, Tartupark.Booking) when action in [:new, :create, :index] do
#     user.role == "customer"
#   end
#
#   def can?(user, action, Tartupark.Booking) when action in [:summary] do
#     user.role == "taxi-driver"
#   end
# end
