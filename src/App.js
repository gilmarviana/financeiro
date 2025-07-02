import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import { FinanceProvider } from './context/FinanceContext'
import Layout from './components/Layout/Layout'
import Dashboard from './components/Dashboard/Dashboard'
import './App.css'

function App() {
  return (
    <Router>
      <FinanceProvider>
        <div className="App">
          <Layout>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/transactions" element={<div>Transações em desenvolvimento...</div>} />
              <Route path="/income" element={<div>Receitas em desenvolvimento...</div>} />
              <Route path="/expenses" element={<div>Despesas em desenvolvimento...</div>} />
              <Route path="/reports" element={<div>Relatórios em desenvolvimento...</div>} />
              <Route path="/categories" element={<div>Categorias em desenvolvimento...</div>} />
            </Routes>
          </Layout>
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#363636',
                color: '#fff',
              },
              success: {
                style: {
                  background: '#48bb78',
                },
              },
              error: {
                style: {
                  background: '#f56565',
                },
              },
            }}
          />
        </div>
      </FinanceProvider>
    </Router>
  )
}

export default App
