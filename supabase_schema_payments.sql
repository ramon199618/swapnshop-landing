-- Payment Integration Schema für Swap&Shop

-- Tabelle für monatliche Limits und Add-ons
CREATE TABLE IF NOT EXISTS user_monthly_limits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  month_key VARCHAR(7) NOT NULL, -- Format: YYYY-MM
  swaps_used INTEGER DEFAULT 0,
  sells_used INTEGER DEFAULT 0,
  addon_swaps_remaining INTEGER DEFAULT 0,
  addon_sells_remaining INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, month_key)
);

-- Tabelle für Zahlungen
CREATE TABLE IF NOT EXISTS payments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  provider VARCHAR(20) NOT NULL CHECK (provider IN ('stripe', 'payrexx')),
  type VARCHAR(30) NOT NULL CHECK (type IN ('premium_monthly', 'premium_yearly', 'addon_swaps_5', 'addon_sells_5')),
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'CHF',
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  provider_ref VARCHAR(255), -- Externe Referenz (Stripe Session ID, Payrexx Transaction ID)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index für Performance
CREATE INDEX IF NOT EXISTS idx_user_monthly_limits_user_month ON user_monthly_limits(user_id, month_key);
CREATE INDEX IF NOT EXISTS idx_payments_user_status ON payments(user_id, status);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);

-- Funktion für automatischen Monats-Reset
CREATE OR REPLACE FUNCTION reset_monthly_limits_if_needed(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
  current_month_key VARCHAR(7);
  existing_record RECORD;
BEGIN
  -- Aktueller Monat im Format YYYY-MM
  current_month_key := TO_CHAR(NOW(), 'YYYY-MM');
  
  -- Prüfe ob bereits ein Eintrag für diesen Monat existiert
  SELECT * INTO existing_record 
  FROM user_monthly_limits 
  WHERE user_id = user_uuid AND month_key = current_month_key;
  
  -- Wenn kein Eintrag existiert, erstelle einen neuen mit Reset-Werten
  IF existing_record IS NULL THEN
    INSERT INTO user_monthly_limits (user_id, month_key, swaps_used, sells_used, addon_swaps_remaining, addon_sells_remaining)
    VALUES (user_uuid, current_month_key, 0, 0, 0, 0);
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger für automatische updated_at Updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_monthly_limits_updated_at 
  BEFORE UPDATE ON user_monthly_limits 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at 
  BEFORE UPDATE ON payments 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) Policies
ALTER TABLE user_monthly_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Policies für user_monthly_limits
CREATE POLICY "Users can view their own monthly limits" ON user_monthly_limits
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own monthly limits" ON user_monthly_limits
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own monthly limits" ON user_monthly_limits
  FOR UPDATE USING (auth.uid() = user_id);

-- Policies für payments
CREATE POLICY "Users can view their own payments" ON payments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments" ON payments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Admin kann alle Payments sehen (für Webhook-Verarbeitung)
CREATE POLICY "Admin can view all payments" ON payments
  FOR SELECT USING (auth.role() = 'service_role'); 