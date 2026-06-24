
from cmath import pi


config_init = [-44.81,-108.14,-49.1,-33.39,83.01,38.73]
config_final = [-95.54,-147.67,-48.7,-193.08,12.54,90.04]

config_init_rad = list(map(lambda x: x*pi/180, config_init))
config_final_rad = list(map(lambda x: x*pi/180, config_final))

def normalizacion(config):
    for i in range(len(config)):
        if i == 2:
            config[i] = (config[i] + pi) / (2*pi)
        else:
            config[i] = (config[i] + 2*pi) / (4*pi)
    
    return config
        
config_init_norm = normalizacion(config_init_rad)
config_final_norm = normalizacion(config_final_rad)

print("Config init norm: ", config_init_norm)
print("Config final norm: ", config_final_norm)
