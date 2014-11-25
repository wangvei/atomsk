MODULE center
!
!**********************************************************************************
!*  CENTER                                                                        *
!**********************************************************************************
!* This module shifts all atoms so that the atom with the given index is at the   *
!* center of the box. If center_atom is zero or negative, then atoms are          *
!* shifted so that the center of mass is at the center of the box.                *
!**********************************************************************************
!* (C) April 2014 - Pierre Hirel                                                  *
!*     Unité Matériaux Et Transformations (UMET),                                 *
!*     Université de Lille 1, Bâtiment C6, F-59655 Villeneuve D'Ascq (FRANCE)     *
!*     pierre.hirel@univ-lille1.fr                                                *
!* Last modification: P. Hirel - 25 Nov. 2014                                     *
!**********************************************************************************
!* This program is free software: you can redistribute it and/or modify           *
!* it under the terms of the GNU General Public License as published by           *
!* the Free Software Foundation, either version 3 of the License, or              *
!* (at your option) any later version.                                            *
!*                                                                                *
!* This program is distributed in the hope that it will be useful,                *
!* but WITHOUT ANY WARRANTY; without even the implied warranty of                 *
!* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  *
!* GNU General Public License for more details.                                   *
!*                                                                                *
!* You should have received a copy of the GNU General Public License              *
!* along with this program.  If not, see <http://www.gnu.org/licenses/>.          *
!**********************************************************************************
!
USE atoms
USE comv
USE messages
USE subroutines
!
!
CONTAINS
!
!
SUBROUTINE CENTER_XYZ(H,P,S,center_atom,SELECT)
!
!
IMPLICIT NONE
CHARACTER(LEN=2):: species
CHARACTER(LEN=128):: msg
LOGICAL,DIMENSION(:),ALLOCATABLE,INTENT(IN):: SELECT  !mask for atom list
INTEGER:: i
INTEGER,INTENT(IN):: center_atom  !index of atom that must be centered; if <=0, center the center of mass
REAL(dp):: smass   !mass of an atom
REAL(dp):: totmass !total mass of all atoms
REAL(dp),DIMENSION(3):: box_center  !coordinates of the center of the box
REAL(dp),DIMENSION(3):: Vcom        !coordinates of the center of mass of the atoms
REAL(dp),DIMENSION(3):: Vshift      !shift vector to apply to all atoms
REAL(dp),DIMENSION(3,3),INTENT(IN):: H   !vectors of supercell
REAL(dp),DIMENSION(:,:),ALLOCATABLE,INTENT(INOUT):: P, S  !positions of atoms, shells
!
species = ''
!
WRITE(msg,*) 'Entering CENTER_XYZ: ', center_atom
CALL ATOMSK_MSG(999,(/TRIM(msg)/),(/0.d0/))
!
!
!Define the center of the box
box_center(:) = ( H(1,:) + H(2,:) + H(3,:) ) / 2.d0
!
!
!
100 CONTINUE
CALL ATOMSK_MSG(2118,(/""/),(/DBLE(center_atom)/))
!
IF( center_atom <= 0 ) THEN
  !place the center of mass at the center of the box
  !Determine the position of the center of mass
  totmass = 0.d0
  Vcom(:) = 0.d0
  DO i=1,SIZE(P,1)
    CALL ATOMSPECIES(P(i,4),species)
    CALL ATOMMASS(species,smass)
    Vcom(:) = Vcom(:) + smass*P(i,1:3)
    totmass = totmass + smass
  ENDDO
  Vcom(:) = Vcom(:) / totmass
  Vshift(:) = box_center(:) - Vcom(:)
  !
ELSE
  IF( center_atom<SIZE(P,1) ) THEN
    !place the atom with the given index at the center of the box
    Vshift(:) = box_center(:) - P(center_atom,1:3)
  ELSE
    nwarn=nwarn+1
    CALL ATOMSK_MSG(2742,(/''/),(/DBLE(center_atom)/))
    GOTO 1000
  ENDIF
  !
ENDIF
!
WRITE(msg,'(a14,3f9.3)') 'Shift vector: ', Vshift(:)
CALL ATOMSK_MSG(999,(/TRIM(msg)/),(/0.d0/))
!
!Shift all atoms
DO i=1,SIZE(P,1)
  P(i,1:3) = P(i,1:3) + Vshift(:)
ENDDO
IF( ALLOCATED(S) ) THEN
  DO i=1,SIZE(S,1)
    S(i,1:3) = S(i,1:3) + Vshift(:)
  ENDDO
ENDIF
!
CALL ATOMSK_MSG(2119,(/''/),(/Vshift(1),Vshift(2),Vshift(3)/))
!
!
!
1000 CONTINUE
!
!
!
END SUBROUTINE CENTER_XYZ
!
END MODULE center