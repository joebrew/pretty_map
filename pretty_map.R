library(rgdal)
library(rgeos)

# Read in shapefile
shp <- readOGR('africa_shapefile/', 'africa_shapefile')

# Subset for testing
shp <- shp[shp$COUNTRYAFF %in% c('Mozambique', 'South Africa') &
             shp$Land_Type == 'Primary land',]

# Make projected if necessary
shp <- spTransform(shp, CRS('+init=epsg:3347'))

# Get internal buffers
n_buffers <- 3
buffer_distance <- 50000
buffer_list <- list()
for (i in 1:n_buffers){
  buffer_list[[i]] <-
    rgeos::gBuffer(shp, width = -1 * buffer_distance * i)
}

# Get lat lon version again
shp <- spTransform(shp, CRS("+init=epsg:4326"))
buffer_list <- lapply(buffer_list,
                      function(x){
                        spTransform(x,
                                    CRS("+init=epsg:4326"))
                      })

# Plot the outside
plot(shp)

# Plot the internal buffers
colors <- colorRampPalette(c('yellow', 'darkred'))(n_buffers)
for (i in 1:n_buffers){
  message(i)
  plot(buffer_list[[i]],
       add = TRUE,
       col = adjustcolor(colors[i], alpha.f = 0.2),
       border = NA)
}
