# -*- coding: utf-8 -*-
"""
Created on Wed Mar  6 12:17:21 2019

@author: Thies
"""

## Import packages
import numpy as np
from scipy.stats import norm

## Choose parameter values
S_0 = 100
r = 0.06
sigma = 0.2
K = 99
T = 1
N = 30
R = 100000
delta = T / N

def Generate_Price_Sequence_Euler(epsilons):    
    S = []
    S.append(S_0)
    for i,e in enumerate(epsilons):
        St = S[i] + r * S[i] * delta + sigma * S[i] * e * np.sqrt(delta)
        S.append(St)
    return S[1:]

def Generate_Price_Sequence_Milstein(epsilons):    
    S = []
    S.append(S_0)
    for i,e in enumerate(epsilons):
        St = S[i] * (1 + (r - 0.5 * sigma**2) * delta + sigma * e * np.sqrt(delta) + 0.5 * sigma**2 * e**2 * delta)
        S.append(St)
    return S[1:]

def Calculate_Value_Asian_Call(S):
    A = np.mean(S)
    C = max((A - K), 0)
    return C

def MC_Asian_Call():
    C_list = []
    
    for i in range(0,R):
        epsilons = np.random.randn(N)
        S = Generate_Price_Sequence_Milstein(epsilons)
        C = Calculate_Value_Asian_Call(S)
        C_list.append(C)
    return C_list

def Antithetic_MC_Asian_Call():
    C_list = []
    
    for i in range(0,R):
        epsilons = np.random.randn(N)
        S_Plus = Generate_Price_Sequence_Milstein(epsilons)
        C_Plus = Calculate_Value_Asian_Call(S_Plus)
        S_Minus = Generate_Price_Sequence_Milstein(-epsilons)
        C_Minus = Calculate_Value_Asian_Call(S_Minus)
        C = (C_Plus+ C_Minus) / 2
        C_list.append(C)
    
    return C_list

## Simulated value Asian call option
C_list = MC_Asian_Call()
C_list_discount = [np.exp(-r * T) * c for c in C_list]
SE_MC = np.std(C_list_discount) / np.sqrt(R)
Estimate_MC = np.mean(C_list_discount)
Upper_Bound_95_CI = Estimate_MC + norm.ppf(0.975) * SE_MC
Lower_Bound_95_CI = Estimate_MC + norm.ppf(0.025) * SE_MC

## Simulated value Asian call option using antithetic variable technique
C_list_anti = Antithetic_MC_Asian_Call()
C_list_anti_discount = [np.exp(-r * T) * c for c in C_list_anti]
SE_MC_anti = np.std(C_list_anti_discount) / np.sqrt(R)
Estimate_MC_anti = np.mean(C_list_anti_discount)
Upper_Bound_95_CI_anti = Estimate_MC_anti + norm.ppf(0.975) * SE_MC_anti
Lower_Bound_95_CI_anti = Estimate_MC_anti + norm.ppf(0.025) * SE_MC_anti

