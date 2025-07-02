import { supabase } from '../lib/supabase'

export const transactionService = {
  // Buscar todas as transações
  async getTransactions() {
    try {
      const { data, error } = await supabase
        .from('transactions')
        .select(`
          *,
          categories(*)
        `)
        .order('date', { ascending: false })
      
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error: error.message }
    }
  },

  // Criar nova transação
  async createTransaction(transaction) {
    try {
      const { data, error } = await supabase
        .from('transactions')
        .insert([transaction])
        .select()
      
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error: error.message }
    }
  },

  // Atualizar transação
  async updateTransaction(id, updates) {
    try {
      const { data, error } = await supabase
        .from('transactions')
        .update(updates)
        .eq('id', id)
        .select()
      
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error: error.message }
    }
  },

  // Deletar transação
  async deleteTransaction(id) {
    try {
      const { error } = await supabase
        .from('transactions')
        .delete()
        .eq('id', id)
      
      if (error) throw error
      return { error: null }
    } catch (error) {
      return { error: error.message }
    }
  },

  // Buscar transações por período
  async getTransactionsByPeriod(startDate, endDate) {
    try {
      const { data, error } = await supabase
        .from('transactions')
        .select(`
          *,
          categories(*)
        `)
        .gte('date', startDate)
        .lte('date', endDate)
        .order('date', { ascending: false })
      
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error: error.message }
    }
  },

  // Buscar resumo financeiro
  async getFinancialSummary() {
    try {
      const { data, error } = await supabase
        .rpc('get_financial_summary')
      
      if (error) throw error
      return { data, error: null }
    } catch (error) {
      return { data: null, error: error.message }
    }
  }
}