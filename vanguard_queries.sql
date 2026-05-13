CREATE DATABASE ab_testing;
USE ab_testing;

SHOW tables;
RENAME TABLE `client profiles` TO client_profiles;
SHOW tables;
SELECT * FROM client_profiles;
SELECT COUNT(*) FROM client_profiles;
SELECT * FROM experiment_clients;
SELECT COUNT(*) FROM experiment_clients;
SELECT * FROM web_data;
SELECT COUNT(*) FROM web_data;
#DIA 2:
#Pregunta 1. Who are the primary clients using this online process?
#Pregunta 2. Are the primary clients younger or older, new or long-standing?
#Necesitamos hacer join de las tablas: client_profiles y experiment_roster para saber el perfil que tiene cada cliente en cada grupo (control-test)
#Hacemos INNER JOIN porque analizar los clientes que participan en el proyecto. 
SELECT * FROM client_profiles AS cp
INNER JOIN experiment_clients as ec
   ON cp.client_id = ec.client_id;

#Vamos a ver la edad promedio de los clientes:
SELECT ROUND(AVG(cp.clnt_age), 2) AS avg_age
FROM client_profiles AS cp
INNER JOIN experiment_clients as ec
   ON cp.client_id = ec.client_id;
#Comentario: La edad media de los clientes es de 47.32 años 

#Vamos a ver la edad media por cada grupo
SELECT ec.variation,
ROUND(AVG(cp.clnt_age), 2) AS avg_age
FROM client_profiles AS cp
INNER JOIN experiment_clients as ec
   ON cp.client_id = ec.client_id
GROUP BY ec.variation;
#Comentario: La edad media en el grupo de Test es de 47.16 años; mientras que, la edad media del grupo de Control es de 47.5 años. Lo cual podemos decir que, ambos grupos estan balanceados en terminos de edad. 

#Vamos a ver cuantos clientes hay por grupo y por genero
SELECT ec.variation,
cp.gendr,
COUNT(*) AS total_clients
FROM client_profiles AS cp
INNER JOIN experiment_clients as ec
   ON cp.client_id = ec.client_id
GROUP BY ec.variation, cp.gendr
ORDER BY ec.variation; 
#Comentario: Podemos decir que en el grupo de Control hay mayor numero de hombres; al igual que en el grupo de Test. Aunque la diferencia no es muy alta. ALgo ha destacar es que, en ambos grupos el numero de clientes como 'Unknown' es el mas alto. 

#Vamos a ver analizar la antigüedad de los clientes, para determinar si son nuevos o antiguos en la compañia de investment. 
SELECT 
    ec.variation,
    ROUND(AVG(cp.clnt_tenure_yr), 2) AS avg_tenure
FROM client_profiles cp
INNER JOIN experiment_clients ec
    ON cp.client_id = ec.client_id
GROUP BY ec.variation;
#Comentario: Podemos decir que los clientes que participan en el experimento son clientes fieles, es decir, con bastante antigüedad ya que superan ambos grupos los 10 años. Además, la diferencia es mínima, por lo que vemos aqui tambien los grupos balanceados. 

#Vamos a analizar el balance de los clientes con los grupos. 
SELECT 
    ec.variation,
    ROUND(AVG(cp.bal), 2) AS avg_balance
FROM client_profiles cp
INNER JOIN experiment_clients ec
    ON cp.client_id = ec.client_id
GROUP BY ec.variation;
#Comentario: los grupos siguen estando balanceados en terminos economicos, vemos que el grupo Test tiene una media inferior, aunque es relativamente pequeña.

#DIA 3:
#Objetivo del proyecto: Ver si la nueva interfaz funciona mejor que el sistema tradicional. Para ello, utilizamos una serie de KPIS:
#1. Completion Rate: The proportion of users who reach the final 'confirm' step.
#2. Time Spent on Each Step: The average duration users spend on each step.
#3. Error Rate: If there's a step where users go back to a previous step, it may indicate confusion or an error
#Para utilizar estos KPIs, vamos a trabajar con las tablas: experiment_clients y web_data
#Hacemos INNER JOIN porque analizar los clientes que participan en el proyecto. 

SELECT * FROM web_data AS wd
INNER JOIN experiment_clients AS ec
    ON wd.client_id = ec.client_id;

#1. Analisis KPI - Completion Rate (completion rate = (completed users / total users) * 100)
#Vamos a calcular los usuarios que completaron el proceso, llegaron hasta el final 'confirm'
SELECT 
    ec.variation,
    COUNT(DISTINCT wd.client_id) AS completed_users
FROM web_data AS wd
INNER JOIN experiment_clients AS ec
    ON wd.client_id = ec.client_id
WHERE wd.process_step = 'confirm'
GROUP BY ec.variation;

#Vamos a calcular KPI - Completion rate
SELECT 
    ec.variation,
    COUNT(DISTINCT wd.client_id) AS completed_users,
    ROUND(COUNT(DISTINCT wd.client_id) * 100.0 /
        (SELECT COUNT(DISTINCT client_id)
            FROM experiment_clients
            WHERE variation = ec.variation),2) AS completion_rate
FROM web_data AS wd
INNER JOIN experiment_clients ec
    ON wd.client_id = ec.client_id
WHERE wd.process_step = 'confirm'
GROUP BY ec.variation;
#Comentario: Podemos ver que el completion rate del grupo Test es superior, lo cual indica que la nueva inte4rfaz podria estar ayudando a que más usuarios completen el proceso hasta el final.


