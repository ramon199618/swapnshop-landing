-- Stores Schema für Swap&Shop

-- Tabelle für Stores
CREATE TABLE IF NOT EXISTS stores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  logo_url TEXT,
  type INTEGER NOT NULL CHECK (type IN (1, 2, 3)), -- 1: Privater Flohmarkt, 2: Kleiner Store, 3: Professioneller Store
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index für Performance
CREATE INDEX IF NOT EXISTS idx_stores_user_id ON stores(user_id);
CREATE INDEX IF NOT EXISTS idx_stores_status ON stores(status);
CREATE INDEX IF NOT EXISTS idx_stores_created_at ON stores(created_at);

-- Trigger für automatische updated_at Updates
CREATE TRIGGER update_stores_updated_at 
  BEFORE UPDATE ON stores 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) Policies
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;

-- Policies für stores
CREATE POLICY "Users can view all active stores" ON stores
  FOR SELECT USING (status = 'active');

CREATE POLICY "Users can view their own stores" ON stores
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own stores" ON stores
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own stores" ON stores
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own stores" ON stores
  FOR DELETE USING (auth.uid() = user_id); 