json.array!(@advtypes) do |advtype|
  json.extract! advtype, :id
  json.url advtype_url(advtype, format: :json)
end
