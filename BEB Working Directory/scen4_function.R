
# Scenario 4: Top 100 Agency Transition

scen4_emissions_model <- function(assumed_bus_life = 14, 
                                  elec_eff_total = (elec_transm_dist_eff * plug_eff),
                                  consumption_proportion = 0.5,
                                  batt_replace = 0,
                                  largest_pack = FALSE,
                                  DOD = 0.7,
                                  egrid_reduction = "Average"){
  
  source("base_function.R")
  source("scen3_function.R")
  
  base_case <- base_emissions_model(assumed_bus_life = assumed_bus_life,
                                    elec_eff_total = elec_eff_total,
                                    consumption_proportion = consumption_proportion,
                                    batt_replace = batt_replace,
                                    largest_pack = largest_pack,
                                    DOD = DOD,
                                    egrid_reduction = egrid_reduction)
  scen_3 <- scen3_emissions_model(assumed_bus_life = assumed_bus_life,
                                  elec_eff_total = elec_eff_total,
                                  consumption_proportion = consumption_proportion,
                                  batt_replace = batt_replace,
                                  largest_pack = largest_pack,
                                  DOD = DOD,
                                  egrid_reduction = egrid_reduction)
  
  top_agencies <- bus_mileage %>% group_by(NTD.ID) %>% summarise(Agency.bus.count = sum(Total.Fleet.Vehicles))
  top_agencies <- as.data.frame(top_agencies)
  top_agencies <- top_agencies[order(top_agencies$Agency.bus.count, decreasing = TRUE),]
  top_agencies <- top_agencies[1:100, 1]
  
  
  # Those in the largest 100 agencies will follow the scenario 3 pathway
  top_scen3 <- scen_3[scen_3$NTD.ID %in% top_agencies,]
  
  # Those not included in these agencies will follow the base case pathway
  top_base <- base_case[!(base_case$NTD.ID %in% top_agencies),]
  
  top_base$cFuel.Type <- NA
  
  
  top_base$top <- 0
  top_scen3$top <- 1
  
  print(sum(base_case$fuel.wtw..CO2e..mt)/1000000)
  print(sum(top_base$fuel.wtw..CO2e..mt)/1000000)
  print(sum(top_scen3$fuel.wtw..CO2e..mt)/1000000)
  
  
  bus_data <- rbind.data.frame(top_base, top_scen3)

  
  # Group according to scenario
  final_data <- bus_data %>% 
    group_by(NTD.ID,
             Agency.Name.x,
             Modes,
             Fuel.Type,
             cFuel.Type,
             Address.Line.1,
             City,
             State,
             Zip.Code,
             Final.Year,
             Year.Start,
             batt_size,
             top) %>%
    summarize(Total.Fleet.Vehicles = sum(Total.Fleet.Vehicles),
              Active.Fleet.Vehicles = sum(Active.Fleet.Vehicles),
              Total.Miles.on.Active.Vehicles.During.Period = sum(Total.Miles.on.Active.Vehicles.During.Period),
              batt_VOC..mt = sum(batt_VOC..mt),
              batt_CO..mt = sum(batt_CO..mt),
              batt_NOx..mt  = sum(batt_NOx..mt),
              batt_PM10..mt  = sum(batt_PM10..mt),
              batt_PM2.5..mt  = sum(batt_PM2.5..mt),
              batt_SOx..mt  = sum(batt_SOx..mt),
              batt_BC..mt  = sum(batt_BC..mt),
              batt_OC..mt  = sum(batt_OC..mt),
              batt_CO2e..mt  = sum(batt_CO2e..mt),
              fuel.wtw..NOx..mt = sum(fuel.wtw..NOx..mt),
              fuel.wtw..CO2e..mt = sum(fuel.wtw..CO2e..mt),
              fuel.wtw..CO..mt = sum(fuel.wtw..CO..mt),
              fuel.wtw..PM10..mt = sum(fuel.wtw..PM10..mt),
              fuel.wtw..PM2.5..mt = sum(fuel.wtw..PM2.5..mt),
              fuel.wtw..VOC..mt = sum(fuel.wtw..VOC..mt),
              fuel.wtw..SOx..mt = sum(fuel.wtw..SOx..mt))
  
  return(final_data)
  
}