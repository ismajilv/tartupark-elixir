defmodule Tartupark.HTTPoisonMock do
    def get!(url, %{"param" => param}) do
      # if param == "pickup" do
      #   # %{"origins" => origin} = Regex.named_captures(~r/origins=(?<origins>\D+\d+)/, url)
      #   %{"destinations" => destination} = Regex.named_captures(~r/destinations=(?<destinations>\D+\d+)/, url)
      #   destinationFormatted = Enum.join(String.split(destination, "+"), "_")
      #   time_to_pickup_data = Path.absname(destinationFormatted <> ".json", "test/fixtures")
  
      #   %HTTPoison.Response{
      #     body: File.read!(time_to_pickup_data)
      #   }
      # else
      #   %{"origins" => origin, "destinations" => destination} =
      #     Regex.named_captures(~r/origins=(?<origins>\D+\d+)\D+destinations=(?<destinations>\D+\d+)/, url)
      #   originFormatted = Enum.join(String.split(origin, "+"), "_")
      #   destinationFormatted = Enum.join(String.split(destination, "+"), "_")
      #   trip_duration_data = Path.absname(originFormatted <> "__" <> destinationFormatted <> ".json", "test/fixtures")
  
      #   %HTTPoison.Response{
      #     body: File.read!(trip_duration_data)
      #   }
      # end
    end
end  