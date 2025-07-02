import React, { createContext, useContext, useReducer, useEffect } from 'react'
import { transactionService } from '../services/transactionService'
import { categoryService } from '../services/categoryService'
import toast from 'react-hot-toast'

const FinanceContext = createContext()

const initialState = {
  transactions: [],
  categories: [],
  summary: {
    totalIncome: 0,
    totalExpenses: 0,
    balance: 0
  },
  loading: false,
  error: null
}

function financeReducer(state, action) {
  switch (action.type) {
    case 'SET_LOADING':
      return { ...state, loading: action.payload }
    
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false }
    
    case 'SET_TRANSACTIONS':
      return { ...state, transactions: action.payload, loading: false }
    
    case 'ADD_TRANSACTION':
      return { 
        ...state, 
        transactions: [action.payload, ...state.transactions],
        loading: false 
      }
    
    case 'UPDATE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.map(t => 
          t.id === action.payload.id ? action.payload : t
        ),
        loading: false
      }
    
    case 'DELETE_TRANSACTION':
      return {
        ...state,
        transactions: state.transactions.filter(t => t.id !== action.payload),
        loading: false
      }
    
    case 'SET_CATEGORIES':
      return { ...state, categories: action.payload, loading: false }
    
    case 'ADD_CATEGORY':
      return { 
        ...state, 
        categories: [...state.categories, action.payload],
        loading: false 
      }
    
    case 'UPDATE_CATEGORY':
      return {
        ...state,
        categories: state.categories.map(c => 
          c.id === action.payload.id ? action.payload : c
        ),
        loading: false
      }
    
    case 'DELETE_CATEGORY':
      return {
        ...state,
        categories: state.categories.filter(c => c.id !== action.payload),
        loading: false
      }
    
    case 'SET_SUMMARY':
      return { ...state, summary: action.payload }
    
    default:
      return state
  }
}

export function FinanceProvider({ children }) {
  const [state, dispatch] = useReducer(financeReducer, initialState)

  // Carregar dados iniciais
  useEffect(() => {
    loadInitialData()
  }, [])

  // Calcular resumo quando transações mudarem
  useEffect(() => {
    calculateSummary()
  }, [state.transactions])

  const loadInitialData = async () => {
    dispatch({ type: 'SET_LOADING', payload: true })
    
    try {
      const [transactionsResult, categoriesResult] = await Promise.all([
        transactionService.getTransactions(),
        categoryService.getCategories()
      ])

      if (transactionsResult.error) {
        throw new Error(transactionsResult.error)
      }
      
      if (categoriesResult.error) {
        throw new Error(categoriesResult.error)
      }

      dispatch({ type: 'SET_TRANSACTIONS', payload: transactionsResult.data || [] })
      dispatch({ type: 'SET_CATEGORIES', payload: categoriesResult.data || [] })
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message })
      toast.error('Erro ao carregar dados: ' + error.message)
    }
  }

  const calculateSummary = () => {
    const summary = state.transactions.reduce((acc, transaction) => {
      if (transaction.type === 'income') {
        acc.totalIncome += parseFloat(transaction.amount)
      } else {
        acc.totalExpenses += parseFloat(transaction.amount)
      }
      return acc
    }, { totalIncome: 0, totalExpenses: 0 })

    summary.balance = summary.totalIncome - summary.totalExpenses
    dispatch({ type: 'SET_SUMMARY', payload: summary })
  }

  const addTransaction = async (transaction) => {
    dispatch({ type: 'SET_LOADING', payload: true })
    
    try {
      const result = await transactionService.createTransaction(transaction)
      
      if (result.error) {
        throw new Error(result.error)
      }

      dispatch({ type: 'ADD_TRANSACTION', payload: result.data[0] })
      toast.success('Transação adicionada com sucesso!')
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message })
      toast.error('Erro ao adicionar transação: ' + error.message)
    }
  }

  const updateTransaction = async (id, updates) => {
    dispatch({ type: 'SET_LOADING', payload: true })
    
    try {
      const result = await transactionService.updateTransaction(id, updates)
      
      if (result.error) {
        throw new Error(result.error)
      }

      dispatch({ type: 'UPDATE_TRANSACTION', payload: result.data[0] })
      toast.success('Transação atualizada com sucesso!')
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message })
      toast.error('Erro ao atualizar transação: ' + error.message)
    }
  }

  const deleteTransaction = async (id) => {
    dispatch({ type: 'SET_LOADING', payload: true })
    
    try {
      const result = await transactionService.deleteTransaction(id)
      
      if (result.error) {
        throw new Error(result.error)
      }

      dispatch({ type: 'DELETE_TRANSACTION', payload: id })
      toast.success('Transação removida com sucesso!')
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message })
      toast.error('Erro ao remover transação: ' + error.message)
    }
  }

  const addCategory = async (category) => {
    dispatch({ type: 'SET_LOADING', payload: true })
    
    try {
      const result = await categoryService.createCategory(category)
      
      if (result.error) {
        throw new Error(result.error)
      }

      dispatch({ type: 'ADD_CATEGORY', payload: result.data[0] })
      toast.success('Categoria adicionada com sucesso!')
    } catch (error) {
      dispatch({ type: 'SET_ERROR', payload: error.message })
      toast.error('Erro ao adicionar categoria: ' + error.message)
    }
  }

  const value = {
    ...state,
    addTransaction,
    updateTransaction,
    deleteTransaction,
    addCategory,
    loadInitialData
  }

  return (
    <FinanceContext.Provider value={value}>
      {children}
    </FinanceContext.Provider>
  )
}

export function useFinance() {
  const context = useContext(FinanceContext)
  if (!context) {
    throw new Error('useFinance deve ser usado dentro de um FinanceProvider')
  }
  return context
}