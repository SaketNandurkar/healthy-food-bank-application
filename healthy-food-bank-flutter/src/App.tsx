/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  Leaf, 
  Search, 
  ArrowLeft, 
  ShoppingBasket, 
  Wallet, 
  User, 
  Home, 
  ChevronRight, 
  Plus, 
  Minus, 
  Trash2, 
  MapPin, 
  Bell, 
  Settings, 
  HelpCircle, 
  Mail, 
  LogOut, 
  CheckCircle2, 
  XCircle, 
  LayoutGrid, 
  Store, 
  ShieldCheck, 
  RefreshCw, 
  Filter, 
  Edit3, 
  QrCode,
  ArrowRight,
  Info,
  Lock,
  Eye,
  Menu,
  ReceiptText,
  Package,
  MessageSquare
} from 'lucide-react';
import { Screen, UserRole, Product, Order } from './types';
import { PRODUCTS, ORDERS } from './constants';

// --- Components ---

const Navbar = ({ currentScreen, setScreen, role }: { currentScreen: Screen, setScreen: (s: Screen) => void, role: UserRole }) => {
  const isCustomer = role === 'customer';
  const isVendor = role === 'vendor';
  const isAdmin = role === 'admin';

  return (
    <nav className="fixed bottom-0 left-0 right-0 border-t border-slate-200 bg-white/95 backdrop-blur-md dark:border-slate-800 dark:bg-background-dark/95 z-50">
      <div className="flex h-16 items-center justify-around px-4">
        <button onClick={() => setScreen('home')} className={`flex flex-col items-center gap-1 ${currentScreen === 'home' ? 'text-primary' : 'text-slate-400'}`}>
          <Home size={24} />
          <span className="text-[10px] font-medium">Home</span>
        </button>
        
        {isCustomer && (
          <>
            <button onClick={() => setScreen('orders')} className={`flex flex-col items-center gap-1 ${currentScreen === 'orders' ? 'text-primary' : 'text-slate-400'}`}>
              <ReceiptText size={24} />
              <span className="text-[10px] font-medium">Orders</span>
            </button>
            <button onClick={() => setScreen('cart')} className={`flex flex-col items-center gap-1 ${currentScreen === 'cart' ? 'text-primary' : 'text-slate-400'}`}>
              <div className="relative">
                <ShoppingBasket size={24} />
                <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-primary text-[10px] text-white font-bold">2</span>
              </div>
              <span className="text-[10px] font-medium">Cart</span>
            </button>
          </>
        )}

        {(isVendor || isAdmin) && (
          <>
            <button onClick={() => setScreen('stock-management')} className={`flex flex-col items-center gap-1 ${currentScreen === 'stock-management' ? 'text-primary' : 'text-slate-400'}`}>
              <Package size={24} />
              <span className="text-[10px] font-medium">Stock</span>
            </button>
            <button onClick={() => setScreen('order-management')} className={`flex flex-col items-center gap-1 ${currentScreen === 'order-management' ? 'text-primary' : 'text-slate-400'}`}>
              <ReceiptText size={24} />
              <span className="text-[10px] font-medium">Orders</span>
            </button>
          </>
        )}

        {isAdmin && (
          <button onClick={() => setScreen('vendor-management')} className={`flex flex-col items-center gap-1 ${currentScreen === 'vendor-management' ? 'text-primary' : 'text-slate-400'}`}>
            <Store size={24} />
            <span className="text-[10px] font-medium">Vendors</span>
          </button>
        )}

        <button onClick={() => setScreen('profile')} className={`flex flex-col items-center gap-1 ${currentScreen === 'profile' ? 'text-primary' : 'text-slate-400'}`}>
          <User size={24} />
          <span className="text-[10px] font-medium">Profile</span>
        </button>
      </div>
      <div className="h-6 bg-transparent"></div>
    </nav>
  );
};

// --- Screens ---

const SplashScreen = ({ onFinish }: { onFinish: () => void }) => {
  useEffect(() => {
    const timer = setTimeout(onFinish, 2500);
    return () => clearTimeout(timer);
  }, [onFinish]);

  return (
    <motion.div 
      initial={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="relative flex h-screen w-full flex-col items-center justify-center overflow-hidden bg-gradient-to-b from-primary to-primary-dark"
    >
      <motion.div 
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className="flex flex-col items-center px-8 text-center"
      >
        <div className="mb-6 flex h-24 w-24 items-center justify-center rounded-full bg-white/20 backdrop-blur-sm shadow-xl">
          <Leaf className="text-white" size={64} />
        </div>
        <h1 className="text-white text-[28px] font-bold tracking-tight leading-tight">
          Healthy Food Bank
        </h1>
        <p className="mt-2 text-white/80 text-sm font-normal leading-normal">
          Fresh & Healthy, Delivered to You
        </p>
      </motion.div>
      <div className="absolute bottom-16 flex items-center justify-center">
        <div className="flex space-x-2">
          <motion.div animate={{ opacity: [0.4, 1, 0.4] }} transition={{ repeat: Infinity, duration: 1.5 }} className="h-1.5 w-1.5 rounded-full bg-white"></motion.div>
          <motion.div animate={{ opacity: [0.4, 1, 0.4] }} transition={{ repeat: Infinity, duration: 1.5, delay: 0.2 }} className="h-1.5 w-1.5 rounded-full bg-white"></motion.div>
          <motion.div animate={{ opacity: [0.4, 1, 0.4] }} transition={{ repeat: Infinity, duration: 1.5, delay: 0.4 }} className="h-1.5 w-1.5 rounded-full bg-white"></motion.div>
        </div>
      </div>
    </motion.div>
  );
};

const LoginScreen = ({ onLogin, onRegister }: { onLogin: (role: UserRole) => void, onRegister: () => void }) => {
  return (
    <motion.div 
      initial={{ x: '100%' }}
      animate={{ x: 0 }}
      exit={{ x: '-100%' }}
      className="relative flex min-h-screen w-full flex-col overflow-x-hidden"
    >
      <header className="relative h-[35vh] w-full bg-gradient-to-br from-primary via-[#7dad5a] to-[#5a8342] curved-bottom flex flex-col items-center justify-center text-white px-6 pb-12">
        <div className="bg-white/20 p-4 rounded-full mb-4">
          <Leaf size={48} />
        </div>
        <h1 className="text-3xl font-bold tracking-tight">Healthy Food Bank</h1>
        <p className="text-white/80 text-sm mt-1">Nourishing communities naturally</p>
      </header>
      <main className="flex-1 px-6 -mt-16 z-10">
        <div className="bg-white dark:bg-slate-900 rounded-xl shadow-xl p-8 border border-primary/10">
          <div className="space-y-6">
            <div>
              <label className="block text-slate-700 dark:text-slate-300 text-sm font-semibold mb-2">Username</label>
              <div className="relative flex items-center">
                <User className="absolute left-4 text-primary/60" size={20} />
                <input className="w-full pl-12 pr-4 py-4 bg-primary/5 border border-primary/20 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all text-slate-900 dark:text-white placeholder:text-slate-400" placeholder="Enter your username" type="text" />
              </div>
            </div>
            <div>
              <label className="block text-slate-700 dark:text-slate-300 text-sm font-semibold mb-2">Password</label>
              <div className="relative flex items-center">
                <Lock className="absolute left-4 text-primary/60" size={20} />
                <input className="w-full pl-12 pr-12 py-4 bg-primary/5 border border-primary/20 rounded-xl focus:ring-2 focus:ring-primary focus:border-transparent outline-none transition-all text-slate-900 dark:text-white placeholder:text-slate-400" placeholder="Enter your password" type="password" />
                <Eye className="absolute right-4 text-slate-400 cursor-pointer hover:text-primary" size={20} />
              </div>
            </div>
            <div className="text-right">
              <button className="text-primary text-sm font-semibold hover:underline">Forgot Password?</button>
            </div>
            <div className="space-y-3 pt-2">
              <button onClick={() => onLogin('customer')} className="w-full bg-gradient-to-r from-primary to-[#5a8342] text-white font-bold py-4 rounded-xl shadow-lg shadow-primary/30 active:scale-[0.98] transition-transform">
                Sign In
              </button>
              <div className="grid grid-cols-2 gap-2">
                <button onClick={() => onLogin('vendor')} className="bg-white border border-primary/30 text-primary font-bold py-2 rounded-lg text-xs">Vendor Login</button>
                <button onClick={() => onLogin('admin')} className="bg-white border border-primary/30 text-primary font-bold py-2 rounded-lg text-xs">Admin Login</button>
              </div>
            </div>
          </div>
        </div>
        <div className="mt-8 text-center">
          <p className="text-slate-600 dark:text-slate-400 text-sm">
            Don't have an account? 
            <button onClick={onRegister} className="text-primary font-bold hover:underline ml-1">Register here</button>
          </p>
        </div>
        <div className="mt-8 mb-10 p-4 bg-primary/10 rounded-lg border border-primary/20">
          <div className="flex items-start gap-3">
            <Info className="text-primary" size={20} />
            <div>
              <p className="text-xs font-bold text-primary uppercase tracking-wider">Demo Accounts</p>
              <p className="text-xs text-slate-600 dark:text-slate-400 mt-1 leading-relaxed">
                To test the app, click the role buttons above.
              </p>
            </div>
          </div>
        </div>
      </main>
    </motion.div>
  );
};

const RegisterScreen = ({ onBack, onRegister }: { onBack: () => void, onRegister: () => void }) => {
  const [role, setRole] = useState<UserRole>('customer');

  return (
    <motion.div 
      initial={{ x: '100%' }}
      animate={{ x: 0 }}
      exit={{ x: '100%' }}
      className="relative mx-auto max-w-[430px] min-h-screen bg-background-light dark:bg-background-dark overflow-x-hidden pb-12"
    >
      <div className="bg-gradient-to-r from-primary to-[#84b367] pt-12 pb-8 px-4 rounded-b-xl shadow-lg">
        <div className="flex items-center justify-between mb-4">
          <button onClick={onBack} className="text-white flex size-10 shrink-0 items-center justify-center rounded-full bg-white/20 backdrop-blur-md cursor-pointer">
            <ArrowLeft size={24} />
          </button>
          <h1 className="text-white text-xl font-bold leading-tight tracking-tight flex-1 text-center pr-10">Register</h1>
        </div>
        <div className="mt-4 px-2">
          <h2 className="text-white text-2xl font-bold">Join Healthy Food Bank</h2>
          <p className="text-white/80 text-sm mt-1">Create an account to start your journey</p>
        </div>
      </div>
      <div className="mx-4 -mt-6 bg-white dark:bg-zinc-900 rounded-xl shadow-xl p-6 flex flex-col gap-5">
        <div className="flex flex-col gap-4">
          <h3 className="text-slate-900 dark:text-slate-100 text-lg font-bold border-b border-primary/10 pb-2">Personal Information</h3>
          <div className="grid grid-cols-2 gap-4">
            <label className="flex flex-col gap-2">
              <span className="text-slate-700 dark:text-slate-300 text-sm font-medium">First Name</span>
              <input className="w-full rounded-lg border-primary/20 bg-background-light dark:bg-zinc-800 dark:border-zinc-700 text-slate-900 dark:text-slate-100 focus:ring-primary focus:border-primary" placeholder="Jane" type="text" />
            </label>
            <label className="flex flex-col gap-2">
              <span className="text-slate-700 dark:text-slate-300 text-sm font-medium">Last Name</span>
              <input className="w-full rounded-lg border-primary/20 bg-background-light dark:bg-zinc-800 dark:border-zinc-700 text-slate-900 dark:text-slate-100 focus:ring-primary focus:border-primary" placeholder="Doe" type="text" />
            </label>
          </div>
          <label className="flex flex-col gap-2">
            <span className="text-slate-700 dark:text-slate-300 text-sm font-medium">Email Address</span>
            <input className="w-full rounded-lg border-primary/20 bg-background-light dark:bg-zinc-800 dark:border-zinc-700 text-slate-900 dark:text-slate-100 focus:ring-primary focus:border-primary" placeholder="jane.doe@example.com" type="email" />
          </label>
        </div>
        <div className="flex flex-col gap-4 mt-2">
          <h3 className="text-slate-900 dark:text-slate-100 text-lg font-bold border-b border-primary/10 pb-2">Account Role</h3>
          <div className="grid grid-cols-3 gap-3">
            <button onClick={() => setRole('customer')} className={`flex flex-col items-center justify-center p-3 rounded-lg border-2 transition-all ${role === 'customer' ? 'border-primary bg-primary/5 text-primary' : 'border-transparent bg-background-light dark:bg-zinc-800 text-slate-500'}`}>
              <User size={24} />
              <span className="text-xs font-semibold mt-1">Customer</span>
            </button>
            <button onClick={() => setRole('vendor')} className={`flex flex-col items-center justify-center p-3 rounded-lg border-2 transition-all ${role === 'vendor' ? 'border-primary bg-primary/5 text-primary' : 'border-transparent bg-background-light dark:bg-zinc-800 text-slate-500'}`}>
              <Store size={24} />
              <span className="text-xs font-semibold mt-1">Vendor</span>
            </button>
            <button onClick={() => setRole('admin')} className={`flex flex-col items-center justify-center p-3 rounded-lg border-2 transition-all ${role === 'admin' ? 'border-primary bg-primary/5 text-primary' : 'border-transparent bg-background-light dark:bg-zinc-800 text-slate-500'}`}>
              <ShieldCheck size={24} />
              <span className="text-xs font-semibold mt-1">Admin</span>
            </button>
          </div>
          {role === 'customer' && (
            <label className="flex flex-col gap-2">
              <span className="text-slate-700 dark:text-slate-300 text-sm font-medium">Select Pickup Point</span>
              <select className="w-full rounded-lg border-primary/20 bg-background-light dark:bg-zinc-800 dark:border-zinc-700 text-slate-900 dark:text-slate-100 focus:ring-primary focus:border-primary">
                <option>Downtown Food Hub</option>
                <option>Westside Community Center</option>
                <option>East Garden Station</option>
              </select>
            </label>
          )}
        </div>
        <div className="mt-4">
          <button onClick={onRegister} className="w-full bg-gradient-to-r from-primary to-[#84b367] text-white font-bold py-4 rounded-xl shadow-md active:scale-[0.98] transition-transform">
            Create Account
          </button>
        </div>
      </div>
    </motion.div>
  );
};

const HomeScreen = ({ role }: { role: UserRole }) => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative flex h-auto min-h-screen w-full flex-col overflow-x-hidden pb-24"
    >
      <div className="flex items-center bg-primary p-4 pb-4 justify-between text-white">
        <div className="w-10"></div>
        <h2 className="text-lg font-bold leading-tight tracking-tight flex-1 text-center">Browse Products</h2>
        <div className="flex items-center gap-2">
          <button className="flex items-center justify-center rounded-full h-10 w-10 bg-transparent hover:bg-white/10 transition-colors">
            <Bell size={24} />
          </button>
          <div className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary/20 border border-white/30 text-sm font-bold">
            JD
          </div>
        </div>
      </div>
      <div className="px-4 py-3">
        <div className="flex items-center justify-between gap-3 rounded-xl border border-primary/20 bg-primary/5 p-4">
          <div className="flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary text-white">
              <MapPin size={20} />
            </div>
            <div className="flex flex-col">
              <p className="text-xs font-medium text-primary uppercase tracking-wider">Pickup Point</p>
              <p className="text-sm font-bold leading-tight">123 Green Street, Sector 5</p>
            </div>
          </div>
          <button className="text-xs font-bold bg-white dark:bg-slate-800 px-3 py-1.5 rounded-lg shadow-sm border border-slate-200 dark:border-slate-700">
            CHANGE
          </button>
        </div>
      </div>
      <div className="sticky top-0 bg-background-light/95 dark:bg-background-dark/95 backdrop-blur-md pt-2 z-40">
        <div className="px-4 pb-3">
          <div className="relative flex w-full items-stretch rounded-xl h-12 shadow-sm">
            <div className="text-slate-400 flex bg-white dark:bg-slate-800 items-center justify-center pl-4 rounded-l-xl border-y border-l border-slate-200 dark:border-slate-700">
              <Search size={20} />
            </div>
            <input className="flex w-full min-w-0 flex-1 border-y border-r border-slate-200 dark:border-slate-700 rounded-r-xl bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-0 focus:ring-0 focus:border-primary h-full placeholder:text-slate-400 px-4 pl-2 text-base font-normal leading-normal" placeholder="Search for fresh produce..." />
          </div>
        </div>
        <div className="flex gap-2 px-4 pb-4 overflow-x-auto no-scrollbar">
          {['All', 'Vegetables', 'Fruits', 'Dairy', 'Grains'].map((cat, i) => (
            <div key={cat} className={`flex h-9 shrink-0 items-center justify-center gap-x-2 rounded-full px-5 ${i === 0 ? 'bg-primary text-white' : 'bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700'}`}>
              <p className={`text-sm ${i === 0 ? 'font-semibold' : 'font-medium'}`}>{cat}</p>
            </div>
          ))}
        </div>
      </div>
      <div className="px-4 grid grid-cols-2 gap-4">
        {PRODUCTS.map((product) => (
          <motion.div 
            key={product.id}
            whileHover={{ y: -4 }}
            className="flex flex-col bg-white dark:bg-slate-800 rounded-xl overflow-hidden shadow-sm border border-slate-100 dark:border-slate-700"
          >
            <div className="relative aspect-square w-full">
              <img alt={product.name} className="h-full w-full object-cover" src={product.image} referrerPolicy="no-referrer" />
              <span className={`absolute top-2 left-2 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${
                product.status === 'in-stock' ? 'bg-green-100 text-green-700' : 
                product.status === 'low-stock' ? 'bg-yellow-100 text-yellow-700' : 'bg-red-100 text-red-700'
              }`}>
                {product.status.replace('-', ' ')}
              </span>
            </div>
            <div className="p-3 flex flex-col flex-1">
              <p className="text-xs text-slate-500 mb-0.5">{product.vendor}</p>
              <h3 className="text-sm font-bold text-slate-900 dark:text-slate-100 leading-tight mb-2 line-clamp-1">{product.name}</h3>
              <p className="text-lg font-bold text-primary mb-3">₹{product.price}</p>
              <button 
                disabled={product.status === 'out-of-stock'}
                className={`w-full py-2 rounded-lg text-xs font-bold flex items-center justify-center gap-1 ${
                  product.status === 'out-of-stock' ? 'bg-slate-300 text-slate-500 cursor-not-allowed' : 'bg-primary text-white'
                }`}
              >
                {product.status === 'out-of-stock' ? 'NOT AVAILABLE' : <><Plus size={14} /> ADD TO CART</>}
              </button>
            </div>
          </motion.div>
        ))}
      </div>
    </motion.div>
  );
};

const CartScreen = () => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="bg-background-light dark:bg-background-dark font-display text-slate-900 dark:text-slate-100 min-h-screen flex flex-col pb-24"
    >
      <header className="sticky top-0 z-50 bg-primary text-white px-4 py-4 flex items-center justify-between shadow-md">
        <div className="flex items-center gap-3">
          <button className="flex items-center justify-center size-10 rounded-full hover:bg-white/20 transition-colors">
            <ArrowLeft size={24} />
          </button>
          <div className="flex flex-col">
            <h1 className="text-xl font-bold leading-tight">Shopping Cart</h1>
            <span className="text-xs font-medium opacity-90">3 Items in your bag</span>
          </div>
        </div>
        <button className="text-white/90 hover:text-white text-sm font-semibold underline decoration-2 underline-offset-4">
          Clear Cart
        </button>
      </header>
      <main className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
        {ORDERS.map((item) => (
          <div key={item.id} className="bg-white dark:bg-slate-800 rounded-xl p-4 shadow-sm flex gap-4 items-center border border-primary/10">
            <div className="size-24 rounded-lg bg-cover bg-center shrink-0 border border-slate-100 dark:border-slate-700 overflow-hidden">
              <img src={item.image} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
            </div>
            <div className="flex-1 flex flex-col h-24 justify-between">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="font-bold text-slate-900 dark:text-slate-100">{item.productName}</h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400">Order ID: {item.orderId}</p>
                </div>
                <button className="text-red-500 hover:bg-red-50 p-1 rounded-full transition-colors">
                  <Trash2 size={20} />
                </button>
              </div>
              <div className="flex justify-between items-center">
                <p className="text-primary font-bold text-lg">₹{item.price * 10}</p>
                <div className="flex items-center gap-3 bg-slate-100 dark:bg-slate-700 rounded-full px-2 py-1">
                  <button className="size-6 flex items-center justify-center rounded-full bg-white dark:bg-slate-600 text-slate-900 dark:text-white shadow-sm">
                    <Minus size={14} />
                  </button>
                  <span className="text-sm font-bold w-4 text-center">{item.quantity}</span>
                  <button className="size-6 flex items-center justify-center rounded-full bg-primary text-white shadow-sm">
                    <Plus size={14} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </main>
      <footer className="fixed bottom-16 left-0 right-0 bg-white dark:bg-slate-900 border-t border-slate-200 dark:border-slate-800 rounded-t-xl p-6 shadow-[0_-4px_10px_rgba(0,0,0,0.05)] space-y-4 z-40">
        <div className="flex justify-between items-center">
          <div className="flex flex-col">
            <span className="text-slate-500 dark:text-slate-400 text-sm">Total Amount</span>
            <span className="text-xs font-medium text-slate-400">For 4 units</span>
          </div>
          <p className="text-2xl font-bold text-primary">₹530</p>
        </div>
        <button className="w-full h-14 bg-gradient-to-r from-primary to-[#7dad5a] text-white font-bold rounded-xl shadow-lg shadow-primary/25 flex items-center justify-center gap-2 active:scale-[0.98] transition-transform">
          <span>Proceed to Checkout</span>
          <ArrowRight size={20} />
        </button>
      </footer>
    </motion.div>
  );
};

const OrdersScreen = () => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative flex min-h-screen w-full flex-col overflow-x-hidden pb-24"
    >
      <div className="bg-primary px-4 pt-12 pb-4 flex items-center gap-4 text-white">
        <button className="p-1 hover:bg-white/10 rounded-full transition-colors">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-xl font-bold flex-1">My Orders</h1>
        <button className="p-1 hover:bg-white/10 rounded-full transition-colors">
          <Search size={24} />
        </button>
      </div>
      <div className="bg-white dark:bg-background-dark border-b border-slate-200 dark:border-slate-800 sticky top-0 z-10">
        <div className="flex">
          <button className="flex-1 py-4 text-sm font-bold border-b-2 border-primary text-primary">Active</button>
          <button className="flex-1 py-4 text-sm font-bold border-b-2 border-transparent text-slate-500 dark:text-slate-400">History</button>
        </div>
      </div>
      <div className="flex-1 overflow-y-auto px-4 py-6 space-y-4">
        <h2 className="text-sm font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 mb-2">Ongoing Deliveries</h2>
        {ORDERS.map((order) => (
          <div key={order.id} className={`bg-white dark:bg-slate-900 rounded-xl shadow-sm border-l-4 overflow-hidden flex flex-col ${
            order.status === 'pending' ? 'border-yellow-400' : 
            order.status === 'processing' ? 'border-blue-400' : 'border-primary'
          }`}>
            <div className="p-4 flex gap-4">
              <div className="w-20 h-20 rounded-lg bg-slate-100 dark:bg-slate-800 flex-shrink-0 overflow-hidden">
                <img src={order.image} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
              </div>
              <div className="flex-1">
                <div className="flex justify-between items-start mb-1">
                  <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wide ${
                    order.status === 'pending' ? 'bg-yellow-100 text-yellow-700' : 
                    order.status === 'processing' ? 'bg-blue-100 text-blue-700' : 'bg-primary/20 text-primary'
                  }`}>{order.status}</span>
                  <span className="text-primary font-bold">${order.price.toFixed(2)}</span>
                </div>
                <h3 className="font-bold text-slate-900 dark:text-slate-100 leading-tight">{order.productName}</h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">Order ID: {order.orderId}</p>
                <p className="text-xs text-slate-500 dark:text-slate-400">Quantity: {order.quantity} unit</p>
              </div>
            </div>
            <div className="px-4 py-3 bg-slate-50 dark:bg-slate-800/50 flex justify-between items-center border-t border-slate-100 dark:border-slate-800">
              <span className="text-xs font-medium text-slate-600 dark:text-slate-400 italic">{order.estimatedDelivery}</span>
              <button className="text-xs font-bold text-primary hover:underline">
                {order.status === 'pending' ? 'Track Order' : order.status === 'processing' ? 'View Details' : 'Reschedule'}
              </button>
            </div>
          </div>
        ))}
      </div>
    </motion.div>
  );
};

const ProfileScreen = ({ onLogout }: { onLogout: () => void }) => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative flex min-h-screen w-full flex-col overflow-x-hidden pb-24"
    >
      <div className="bg-gradient-to-br from-primary to-[#4a6d35] p-6 pt-12 pb-8 rounded-b-xl shadow-lg">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-white text-2xl font-bold">Profile</h1>
          <button className="bg-white/20 p-2 rounded-full text-white">
            <Settings size={24} />
          </button>
        </div>
        <div className="flex flex-col items-center text-center">
          <div className="relative">
            <div className="size-24 rounded-full border-4 border-white/30 bg-cover bg-center overflow-hidden">
              <img src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=800&auto=format&fit=crop" className="w-full h-full object-cover" referrerPolicy="no-referrer" />
            </div>
            <div className="absolute bottom-0 right-0 bg-white p-1.5 rounded-full shadow-md">
              <Edit3 className="text-primary" size={14} />
            </div>
          </div>
          <h2 className="text-white text-xl font-bold mt-4">Alex Thompson</h2>
          <p className="text-white/80 text-sm">alex.t@example.com</p>
          <div className="mt-3 inline-flex items-center px-3 py-1 bg-white/20 rounded-full">
            <CheckCircle2 className="text-white mr-1" size={12} />
            <span className="text-white text-xs font-semibold tracking-wide uppercase">Customer</span>
          </div>
        </div>
      </div>
      <div className="flex-1 px-4 py-6 space-y-6 overflow-y-auto">
        <div>
          <h3 className="text-slate-500 dark:text-slate-400 text-xs font-bold uppercase tracking-wider mb-2 ml-2">Account</h3>
          <div className="bg-white dark:bg-slate-800 rounded-xl overflow-hidden shadow-sm border border-slate-100 dark:border-slate-700">
            <button className="w-full flex items-center gap-4 px-4 py-3 active:bg-slate-50 transition-colors">
              <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary"><User size={20} /></div>
              <p className="flex-1 text-left text-base font-medium">Edit Profile</p>
              <ChevronRight className="text-slate-400" size={20} />
            </button>
            <div className="h-px bg-slate-100 dark:bg-slate-700 ml-14"></div>
            <button className="w-full flex items-center gap-4 px-4 py-3 active:bg-slate-50 transition-colors">
              <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary"><MapPin size={20} /></div>
              <p className="flex-1 text-left text-base font-medium">Pickup Points</p>
              <ChevronRight className="text-slate-400" size={20} />
            </button>
          </div>
        </div>
        <div>
          <h3 className="text-slate-500 dark:text-slate-400 text-xs font-bold uppercase tracking-wider mb-2 ml-2">Support</h3>
          <div className="bg-white dark:bg-slate-800 rounded-xl overflow-hidden shadow-sm border border-slate-100 dark:border-slate-700">
            <button className="w-full flex items-center gap-4 px-4 py-3 active:bg-slate-50 transition-colors">
              <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary"><HelpCircle size={20} /></div>
              <p className="flex-1 text-left text-base font-medium">Help Center</p>
              <ChevronRight className="text-slate-400" size={20} />
            </button>
            <div className="h-px bg-slate-100 dark:bg-slate-700 ml-14"></div>
            <button className="w-full flex items-center gap-4 px-4 py-3 active:bg-slate-50 transition-colors">
              <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10 text-primary"><Mail size={20} /></div>
              <p className="flex-1 text-left text-base font-medium">Contact Us</p>
              <ChevronRight className="text-slate-400" size={20} />
            </button>
          </div>
        </div>
        <button onClick={onLogout} className="w-full bg-white dark:bg-slate-800 rounded-xl overflow-hidden shadow-sm border border-slate-100 dark:border-slate-700 flex items-center gap-4 px-4 py-4 active:bg-red-50 transition-colors">
          <div className="flex size-10 items-center justify-center rounded-lg bg-red-100 text-red-600"><LogOut size={20} /></div>
          <p className="flex-1 text-left text-base font-semibold text-red-600">Logout</p>
        </button>
        <div className="py-8 text-center">
          <p className="text-slate-400 dark:text-slate-500 text-xs">Version 2.4.1 (Build 108)</p>
          <p className="text-slate-400 dark:text-slate-500 text-xs mt-1">Healthy Food Bank © 2024</p>
        </div>
      </div>
    </motion.div>
  );
};

const StockManagementScreen = () => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative flex min-h-screen w-full flex-col overflow-x-hidden pb-24"
    >
      <header className="sticky top-0 z-10 flex items-center bg-primary p-4 text-white shadow-md">
        <button className="flex size-10 items-center justify-center"><ArrowLeft size={24} /></button>
        <h1 className="flex-1 text-center text-lg font-bold">Stock Management</h1>
        <button className="flex size-10 items-center justify-center"><RefreshCw size={24} /></button>
      </header>
      <div className="grid grid-cols-2 gap-3 p-4">
        <div className="flex flex-col gap-1 rounded-xl bg-primary/10 p-4 border border-primary/20">
          <p className="text-xs font-semibold text-primary uppercase tracking-wider">Total Products</p>
          <p className="text-2xl font-bold text-primary">124</p>
        </div>
        <div className="flex flex-col gap-1 rounded-xl bg-yellow-500/10 p-4 border border-yellow-500/20">
          <p className="text-xs font-semibold text-yellow-600 uppercase tracking-wider">Total Value</p>
          <p className="text-2xl font-bold text-yellow-600">₹45,200</p>
        </div>
        <div className="flex flex-col gap-1 rounded-xl bg-orange-500/10 p-4 border border-orange-500/20">
          <p className="text-xs font-semibold text-orange-600 uppercase tracking-wider">Low Stock</p>
          <p className="text-2xl font-bold text-orange-600">8</p>
        </div>
        <div className="flex flex-col gap-1 rounded-xl bg-blue-500/10 p-4 border border-blue-500/20">
          <p className="text-xs font-semibold text-blue-600 uppercase tracking-wider">Categories</p>
          <p className="text-2xl font-bold text-blue-600">12</p>
        </div>
      </div>
      <div className="px-4 py-2 space-y-3">
        <div className="flex items-center gap-2">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            <input className="w-full rounded-xl border-none bg-slate-200/50 py-3 pl-10 pr-4 focus:ring-2 focus:ring-primary/50 dark:bg-slate-800/50" placeholder="Search products..." type="text" />
          </div>
          <button className="flex size-12 items-center justify-center rounded-xl bg-slate-200/50 dark:bg-slate-800/50">
            <Filter size={20} />
          </button>
        </div>
      </div>
      <div className="flex flex-col gap-4 p-4">
        {PRODUCTS.map((product) => (
          <div key={product.id} className="flex items-center gap-4 rounded-xl bg-white p-3 shadow-sm dark:bg-slate-900 border border-slate-100 dark:border-slate-800">
            <div className="size-20 overflow-hidden rounded-lg bg-slate-100">
              <img src={product.image} className="h-full w-full object-cover" referrerPolicy="no-referrer" />
            </div>
            <div className="flex-1 flex flex-col gap-1">
              <div className="flex items-start justify-between">
                <h3 className="font-bold">{product.name}</h3>
                <span className="rounded bg-primary/10 px-2 py-0.5 text-[10px] font-bold text-primary uppercase">{product.category}</span>
              </div>
              <p className="text-sm font-semibold text-slate-900 dark:text-slate-100">₹{product.price} / {product.unit}</p>
              <div className="mt-1 flex items-center justify-between">
                <span className={`flex items-center gap-1 text-xs font-medium ${product.stock < 10 ? 'text-orange-500' : 'text-primary'}`}>
                  <span className={`size-2 rounded-full ${product.stock < 10 ? 'bg-orange-500 animate-pulse' : 'bg-primary'}`}></span> 
                  {product.stock === 0 ? 'Out of Stock' : `${product.stock < 10 ? 'Low Stock' : 'In Stock'} (${product.stock})`}
                </span>
                <button className="text-primary"><Edit3 size={18} /></button>
              </div>
            </div>
          </div>
        ))}
      </div>
      <button className="fixed bottom-24 right-6 flex size-14 items-center justify-center rounded-full bg-primary text-white shadow-xl z-40">
        <Plus size={32} />
      </button>
    </motion.div>
  );
};

const OrderManagementScreen = () => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative flex min-h-screen w-full flex-col overflow-x-hidden pb-24"
    >
      <header className="sticky top-0 z-50 bg-primary px-4 py-3 flex items-center justify-between text-white shadow-md">
        <div className="flex items-center gap-3">
          <Menu size={24} />
          <h1 className="text-xl font-bold tracking-tight">Order Management</h1>
        </div>
        <button className="relative">
          <Bell size={24} />
          <span className="absolute top-0 right-0 block h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-primary"></span>
        </button>
      </header>
      <nav className="bg-primary pt-1">
        <div className="flex overflow-x-auto no-scrollbar px-2 gap-1">
          <button className="flex-none px-6 py-3 border-b-4 border-white text-white font-bold text-sm">Issued</button>
          <button className="flex-none px-6 py-3 border-b-4 border-transparent text-white/70 font-semibold text-sm">Scheduled</button>
          <button className="flex-none px-6 py-3 border-b-4 border-transparent text-white/70 font-semibold text-sm">Cancelled</button>
        </div>
      </nav>
      <main className="flex-1 overflow-y-auto p-4 space-y-4">
        <div className="flex items-center justify-between gap-4 rounded-xl border-l-8 border-amber-400 bg-amber-50 dark:bg-amber-900/20 p-5 shadow-sm">
          <div className="flex flex-col gap-1">
            <div className="flex items-center gap-2">
              <RefreshCw className="text-amber-600" size={20} />
              <p className="text-slate-900 dark:text-slate-100 text-base font-bold leading-tight">Awaiting Your Response</p>
            </div>
            <p className="text-slate-600 dark:text-slate-400 text-sm font-medium">Please review and respond to 3 new orders.</p>
          </div>
          <ChevronRight className="text-slate-400" />
        </div>
        {ORDERS.map((order) => (
          <div key={order.id} className="flex flex-col rounded-xl border-2 border-amber-200 dark:border-amber-900/40 bg-white dark:bg-slate-900 overflow-hidden shadow-sm">
            <div className="relative h-48 w-full">
              <img src={order.image} className="w-full h-full object-cover" referrerPolicy="no-referrer" />
              <div className="absolute top-3 right-3 bg-amber-400 text-slate-900 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider">New Order</div>
            </div>
            <div className="p-4 space-y-3">
              <div>
                <h3 className="text-lg font-bold text-slate-900 dark:text-slate-100">{order.productName}</h3>
                <div className="mt-2 space-y-1">
                  <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400 text-sm">
                    <User size={16} />
                    <span>Customer: John Doe</span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400 text-sm">
                    <MapPin size={16} />
                    <span>Pickup: Downtown Hub</span>
                  </div>
                  <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400 text-sm">
                    <ShoppingBasket size={16} />
                    <span>Quantity: {order.quantity} • Order {order.orderId}</span>
                  </div>
                </div>
              </div>
              <div className="flex gap-3 pt-2">
                <button className="flex-1 flex items-center justify-center gap-2 h-11 bg-primary text-white rounded-lg font-bold">
                  <CheckCircle2 size={18} /> Accept
                </button>
                <button className="flex-1 flex items-center justify-center gap-2 h-11 bg-red-50 text-red-600 border border-red-200 rounded-lg font-bold">
                  <XCircle size={18} /> Reject
                </button>
              </div>
            </div>
          </div>
        ))}
      </main>
    </motion.div>
  );
};

const VendorManagementScreen = () => {
  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="relative flex h-screen w-full flex-col overflow-hidden max-w-[430px] mx-auto bg-background-light dark:bg-background-dark"
    >
      <header className="bg-primary px-4 pt-12 pb-4 text-white flex items-center justify-between">
        <div className="flex items-center gap-3">
          <ArrowLeft size={24} />
          <h1 className="text-xl font-bold tracking-tight">Vendor Management</h1>
        </div>
        <button className="bg-white/20 hover:bg-white/30 p-2 rounded-full transition-colors flex items-center justify-center">
          <Plus size={24} />
        </button>
      </header>
      <nav className="bg-white dark:bg-slate-900 border-b border-primary/10">
        <div className="flex">
          <button className="flex-1 py-4 text-center border-b-2 border-primary text-primary font-bold text-sm">All Codes</button>
          <button className="flex-1 py-4 text-center border-b-2 border-transparent text-slate-500 dark:text-slate-400 font-medium text-sm">Unused</button>
          <button className="flex-1 py-4 text-center border-b-2 border-transparent text-slate-500 dark:text-slate-400 font-medium text-sm">Used</button>
        </div>
      </nav>
      <main className="flex-1 overflow-y-auto p-4 space-y-4 pb-24">
        {[
          { code: 'VF-90210-XB', status: 'Unused', name: 'Green Valley Organics', date: 'Oct 24, 2023' },
          { code: 'HF-44321-LM', status: 'Used', name: 'Fresh Harvest Co.', date: 'Oct 22, 2023', user: 'Sarah Jenkins' }
        ].map((item, i) => (
          <div key={i} className="bg-white dark:bg-slate-900 rounded-xl p-4 shadow-sm border border-primary/5">
            <div className="flex justify-between items-start mb-3">
              <div className="bg-primary/10 text-primary px-3 py-1 rounded-lg font-mono font-bold text-lg tracking-wider">{item.code}</div>
              <span className={`px-2 py-0.5 rounded-full text-xs font-bold uppercase tracking-wide ${
                item.status === 'Unused' ? 'bg-yellow-100 text-yellow-700' : 'bg-primary/20 text-primary'
              }`}>{item.status}</span>
            </div>
            <div className="space-y-1 mb-4">
              <h3 className="font-bold text-slate-900 dark:text-slate-100">{item.name}</h3>
              <p className="text-sm text-slate-500 dark:text-slate-400 flex items-center gap-1">
                {item.user ? <User size={14} /> : <RefreshCw size={14} />}
                {item.user ? `Redeemed by: ${item.user}` : `Created: ${item.date}`}
              </p>
            </div>
            <div className="flex gap-2">
              <button className="flex-1 bg-primary text-white py-2.5 rounded-lg font-semibold text-sm">View Details</button>
              {item.status === 'Unused' && <button className="px-4 border border-red-200 text-red-600 py-2.5 rounded-lg font-semibold text-sm">Deactivate</button>}
            </div>
          </div>
        ))}
      </main>
      <div className="absolute bottom-24 right-4">
        <button className="bg-primary text-white w-14 h-14 rounded-full shadow-lg flex items-center justify-center">
          <QrCode size={32} />
        </button>
      </div>
    </motion.div>
  );
};

// --- Main App ---

export default function App() {
  const [screen, setScreen] = useState<Screen>('splash');
  const [role, setRole] = useState<UserRole>('customer');

  const handleLogin = (selectedRole: UserRole) => {
    setRole(selectedRole);
    setScreen('home');
  };

  const handleLogout = () => {
    setScreen('login');
  };

  const renderScreen = () => {
    switch (screen) {
      case 'splash': return <SplashScreen onFinish={() => setScreen('login')} />;
      case 'login': return <LoginScreen onLogin={handleLogin} onRegister={() => setScreen('register')} />;
      case 'register': return <RegisterScreen onBack={() => setScreen('login')} onRegister={() => setScreen('login')} />;
      case 'home': return <HomeScreen role={role} />;
      case 'cart': return <CartScreen />;
      case 'orders': return <OrdersScreen />;
      case 'profile': return <ProfileScreen onLogout={handleLogout} />;
      case 'stock-management': return <StockManagementScreen />;
      case 'vendor-management': return <VendorManagementScreen />;
      case 'order-management': return <OrderManagementScreen />;
      default: return <HomeScreen role={role} />;
    }
  };

  const showNavbar = !['splash', 'login', 'register'].includes(screen);

  return (
    <div className="max-w-[430px] mx-auto min-h-screen bg-background-light dark:bg-background-dark shadow-2xl overflow-hidden relative">
      <AnimatePresence mode="wait">
        {renderScreen()}
      </AnimatePresence>
      {showNavbar && <Navbar currentScreen={screen} setScreen={setScreen} role={role} />}
    </div>
  );
}
