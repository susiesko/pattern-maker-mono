export interface BeadColor {
  id: number;
  name: string;
}

export interface BeadFinish {
  id: number;
  name: string;
}

export interface BeadBrand {
  id: number;
  name: string;
  website?: string;
}

export interface BeadSize {
  id: number;
  size: string;
}

export interface BeadType {
  id: number;
  name: string;
}

export interface Bead {
  id: number;
  name: string;
  brand_product_code: string;
  image?: string;
  metadata?: Record<string, unknown>;
  created_at: string;
  updated_at: string;
  brand: BeadBrand;
  // Direct string attributes from the new schema
  shape?: string;
  size?: string;
  color_group?: string;
  glass_group?: string;
  finish?: string;
  dyed?: string;
  galvanized?: string;
  plating?: string;
}

// Filter option types for dropdowns
export interface FilterOption {
  value: string;
  label: string;
  count?: number;
}
