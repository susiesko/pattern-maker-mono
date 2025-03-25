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
  website: string;
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
  image: string;
  metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
  brand: BeadBrand;
  size: BeadSize;
  type: BeadType;
  colors: BeadColor[];
  finishes: BeadFinish[];
}
