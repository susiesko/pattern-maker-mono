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
  brand_product_code?: string;
  brand: BeadBrand;
  shape?: string;
  size?: string;
  color_group?: string;
  finish?: string;
  glass_group?: string;
  dyed?: string;
  galvanized?: string;
  plating?: string;
  image?: string;
  user_inventory?: {
    id: number;
    quantity: number;
    quantity_unit: string;
  } | null;
}

// Filter option types for dropdowns
export interface FilterOption {
  value: string;
  label: string;
  count?: number;
}

// API Response types
export interface PaginatedBeadsResponse {
  data: Bead[];
  pagination: {
    current_page: number;
    per_page: number;
    total_count: number;
    total_pages: number;
    has_more: boolean;
    has_previous: boolean;
  };
}
